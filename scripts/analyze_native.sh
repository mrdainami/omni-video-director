#!/usr/bin/env bash
# analyze.sh — Gemini 3.5 Flash watches a video (frames + audio) and returns beats as JSON.
# Native Gemini File API (resumable upload -> generateContent). One key: GEMINI_API_KEY.
# Requires: curl + jq.  Usage: analyze.sh input/my-clip.mp4 > analysis/beats.json
set -euo pipefail
_ROOT="$(cd "$(dirname "$0")/.." && pwd)"; [ -f "$_ROOT/.env" ] && { set -a; . "$_ROOT/.env"; set +a; }
: "${GEMINI_API_KEY:?GEMINI_API_KEY not set — add it to .env (only needed for the native long-video path)}"
VIDEO="${1:?usage: analyze.sh <video.mp4>}"
MODEL="gemini-3.5-flash"
BASE="https://generativelanguage.googleapis.com"
MIME="video/mp4"
NUM_BYTES=$(wc -c < "$VIDEO" | tr -d ' ')

# 1) start resumable upload -> capture upload URL
UPLOAD_URL=$(curl -s -D - -o /dev/null \
  "$BASE/upload/v1beta/files?key=$GEMINI_API_KEY" \
  -H "X-Goog-Upload-Protocol: resumable" -H "X-Goog-Upload-Command: start" \
  -H "X-Goog-Upload-Header-Content-Length: $NUM_BYTES" \
  -H "X-Goog-Upload-Header-Content-Type: $MIME" \
  -H "Content-Type: application/json" \
  -d '{"file":{"display_name":"source_video"}}' \
  | grep -i "x-goog-upload-url:" | tr -d '\r' | awk '{print $2}')

# 2) upload bytes + finalize
FILE_JSON=$(curl -s "$UPLOAD_URL" \
  -H "X-Goog-Upload-Offset: 0" -H "X-Goog-Upload-Command: upload, finalize" \
  --data-binary "@$VIDEO")
FILE_URI=$(echo "$FILE_JSON" | jq -r '.file.uri')
FILE_NAME=$(echo "$FILE_JSON" | jq -r '.file.name')

# 3) wait for ACTIVE (large videos process a bit)
for i in $(seq 1 40); do
  st=$(curl -s "$BASE/v1beta/$FILE_NAME?key=$GEMINI_API_KEY" | jq -r '.state')
  [ "$st" = "ACTIVE" ] && break
  [ "$st" = "FAILED" ] && { echo "file processing failed" >&2; exit 1; }
  sleep 3
done

read -r -d '' PROMPT <<'EOF' || true
You are a video editor's assistant. Watch this video (frames + audio) and identify the
moments where adding a B-ROLL clip or an on-screen GRAPHIC would most improve it.
Rules:
- Only mark moments that genuinely need visual support: a named concept, a stat/number,
  a list, a claim that wants proof, a place/product/tool mentioned, or a flat talking-head
  stretch that needs energy.
- Use MM:SS timestamps read from the video. end must be after start. Keep each beat 1.5-5s.
- beat_type: "vfx" for real-world/texture/product/screen footage (b-roll);
  "graphic" for typography, stats, diagrams, lists, callouts (anything with real text).
- reason = why this moment needs it. suggestion = the concrete b-roll or graphic to add.
- Return 5-15 beats ordered by start time. Output ONLY the JSON.
EOF

jq -n --arg uri "$FILE_URI" --arg mime "$MIME" --arg prompt "$PROMPT" '{
  contents:[{parts:[{file_data:{mime_type:$mime,file_uri:$uri}},{text:$prompt}]}],
  generationConfig:{
    responseMimeType:"application/json",
    responseSchema:{type:"array",items:{type:"object",
      properties:{start:{type:"string"},end:{type:"string"},
        beat_type:{type:"string",enum:["vfx","graphic"]},
        reason:{type:"string"},suggestion:{type:"string"}},
      required:["start","end","beat_type","reason","suggestion"],
      propertyOrdering:["start","end","beat_type","reason","suggestion"]}}}
}' > /tmp/avd_gemini_body.json

curl -s "$BASE/v1beta/models/$MODEL:generateContent?key=$GEMINI_API_KEY" \
  -H 'Content-Type: application/json' -X POST --data-binary @/tmp/avd_gemini_body.json \
  | jq -r '.candidates[0].content.parts[0].text'
# -> a JSON array [{start:"MM:SS",end:"MM:SS",beat_type,reason,suggestion}]
# The analyze-video skill converts MM:SS -> seconds and writes analysis/beat-plan.md.
