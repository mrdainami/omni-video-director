#!/usr/bin/env bash
# kie.sh — submit / poll / download for kie.ai (standard job envelope).
# Works for gemini-omni-video AND gpt-image-2 (both use /api/v1/jobs/createTask).
# Requires: KIE_API_KEY in env, plus curl + jq.
#
# Usage:
#   kie.sh submit <body.json>        -> prints taskId (and saves it next to the body as <body>.taskid)
#   kie.sh wait   <taskId>           -> polls until done; prints the first result URL
#   kie.sh get    <taskId>           -> one status check (prints state; on success prints url + credits)
#   kie.sh download <url> <dest>     -> saves url to dest
set -euo pipefail
# load .env from the project root (so users just fill .env — no shell export needed)
_ROOT="$(cd "$(dirname "$0")/.." && pwd)"; [ -f "$_ROOT/.env" ] && { set -a; . "$_ROOT/.env"; set +a; }
API="${KIE_BASE_URL:-https://api.kie.ai}"
: "${KIE_API_KEY:?KIE_API_KEY not set — copy .env.example to .env and fill it in}"
cmd="${1:-}"; shift || true

case "$cmd" in
  submit)
    body="$1"
    resp=$(curl -s -X POST "$API/api/v1/jobs/createTask" \
      -H "Authorization: Bearer $KIE_API_KEY" -H "Content-Type: application/json" \
      --data-binary "@$body")
    tid=$(echo "$resp" | jq -r '.data.taskId // empty')
    if [ -z "$tid" ]; then echo "submit failed: $resp" >&2; exit 1; fi
    echo "$tid" | tee "${body%.json}.taskid"   # PERSIST immediately — credits are spent on submit
    ;;
  get)
    tid="$1"
    resp=$(curl -s "$API/api/v1/jobs/recordInfo?taskId=$tid" -H "Authorization: Bearer $KIE_API_KEY")
    state=$(echo "$resp" | jq -r '.data.state // "unknown"')
    echo "state=$state"
    if [ "$state" = "success" ]; then
      echo "$resp" | jq -r '.data.resultJson' | jq -r '.resultUrls[0]'
      echo "credits=$(echo "$resp" | jq -r '.data.creditsConsumed // "?"')" >&2
    elif [ "$state" = "fail" ]; then
      echo "FAIL: $(echo "$resp" | jq -r '.data.failMsg // "unknown"')" >&2; exit 1
    fi
    ;;
  wait)
    tid="$1"
    for i in $(seq 1 120); do
      resp=$(curl -s "$API/api/v1/jobs/recordInfo?taskId=$tid" -H "Authorization: Bearer $KIE_API_KEY")
      state=$(echo "$resp" | jq -r '.data.state // "unknown"')
      case "$state" in
        success) echo "$resp" | jq -r '.data.resultJson' | jq -r '.resultUrls[0]'
                 echo "credits=$(echo "$resp" | jq -r '.data.creditsConsumed // "?"')" >&2; exit 0 ;;
        fail)    echo "FAIL: $(echo "$resp" | jq -r '.data.failMsg')" >&2; exit 1 ;;
        *)       sleep 15 ;;
      esac
    done
    echo "timed out after ~30min" >&2; exit 1
    ;;
  download)
    curl -s -L "$1" -o "$2"; echo "saved $2" ;;
  upload)   # upload a local file to kie, print the hosted URL (for refs / source clips)
    curl -s -X POST "$API/api/v1/files/upload" \
      -H "Authorization: Bearer $KIE_API_KEY" -F "file=@$1" | jq -r '.data.url // .url // empty' ;;
  *) echo "usage: kie.sh {submit|wait|get|download|upload} ..." >&2; exit 1 ;;
esac
