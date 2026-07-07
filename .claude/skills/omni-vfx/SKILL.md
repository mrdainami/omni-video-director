---
name: omni-vfx
description: Generate the VFX version of a beat's segment with Gemini Omni (video-to-video) on kie. Submit, poll, download. Use for type=vfx beats after the prompt is crafted and the user approves the spend.
---

# omni-vfx — Gemini Omni video-to-video (kie)

Transforms a real clip window while keeping the subject + lip-sync. Model: `gemini-omni-video`.

## Before spending — the gate
Omni is billed on submit. **Show the user the cost estimate and get a go.** First time on a fresh account, run `bash scripts/probe-omni.sh` once (a 720p/4s probe) to learn the real `creditsConsumed`, then quote from that.

## Inputs (from the beat)
- The cut segment `assets/<beat>/src.mp4` (made by `assemble` — a ≤10s window).
- The two-part prompt from `craft-prompt`.
- Optional ≤7 reference images (target texture/product/style).

## Build the body + run
1. Host the source clip + refs: `URL=$(bash scripts/kie.sh upload assets/<beat>/src.mp4)`. *(Verify the upload endpoint on your kie account; if it differs, upload via any public host and paste the URL.)*
2. Write `assets/<beat>/omni.json`:
```json
{ "model":"gemini-omni-video",
  "input":{
    "prompt":"PRESERVE ...; CHANGE ...",
    "video_list":[{ "url":"<hosted src url>", "start":0, "ends":8 }],
    "image_urls":["<ref url>"],
    "aspect_ratio":"16:9",
    "resolution":"1080p" } }
```
   - `video_list`: 1 clip, window `ends-start ≤ 10`. `duration` is ignored when a video is given.
   - Quota: `images + videos×2 + character_ids ≤ 7`.
   - `resolution`: `720p` (cheap probe) · `1080p` (edit-ready) · `4k`.
3. `TID=$(bash scripts/kie.sh submit assets/<beat>/omni.json)` → taskId persisted to `omni.taskid`.
4. `bash scripts/kie.sh wait "$TID"` → the result URL → `kie.sh download <url> assets/<beat>/out.mp4`.
5. Record `creditsConsumed` into `assets/<beat>/.gen.json`. Set beat status → 👀 review.

## Known failure modes (tell the user, re-craft don't brute-force)
- **Wrong thing changed / environment drifted** → the CHANGE block named more than one effect, or PRESERVE was too thin. Split the beat / fence harder.
- **Lip-sync broke** → PRESERVE didn't name "exact mouth movements and timing". Add it.
- **Garbled text** → Omni can't do text. Move it to a `graphic-design` beat.
- **Rotation repeats the wrong face past ~180°** → keep the rotation partial, or use a still.

## Then
**GATE 2** — the user watches `out.mp4`. On approval, `assemble` splices it back. Never auto-place.
