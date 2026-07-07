#!/usr/bin/env bash
# probe-omni.sh — one cheap Gemini Omni generation to learn the real per-clip cost.
# Omni is not pre-priced; this prints the actual creditsConsumed. Needs a hosted source clip URL.
# Usage: probe-omni.sh <hosted-source-video-url>
set -euo pipefail
: "${KIE_API_KEY:?set KIE_API_KEY}"
SRC="${1:?usage: probe-omni.sh <hosted source video url>  (upload with: kie.sh upload assets/<beat>/src.mp4)}"
BODY=/tmp/avd_omni_probe.json
cat > "$BODY" <<JSON
{ "model":"gemini-omni-video",
  "input":{
    "prompt":"PRESERVE (do not change): the subject's face, exact mouth movements and timing, clothing, background, lighting, and camera. Keep everything not named below identical to the source. CHANGE (one effect): add a subtle warm colour grade.",
    "video_list":[{ "url":"$SRC", "start":0, "ends":4 }],
    "aspect_ratio":"16:9",
    "resolution":"720p" } }
JSON
echo "probing Omni at 720p/4s (cheapest) ..."
TID=$(bash "$(dirname "$0")/kie.sh" submit "$BODY")
echo "taskId=$TID"
bash "$(dirname "$0")/kie.sh" wait "$TID" || true
echo ">>> read the 'credits=' line above — that's the real per-clip cost. Add it to your notes."
