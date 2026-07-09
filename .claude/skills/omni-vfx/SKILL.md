---
name: omni-vfx
description: Generate the VFX version of a beat's segment with Gemini Omni (video-to-video) on kie. Submit, poll, download. Use for type=vfx beats after the prompt is crafted and the user approves the spend.
---

# omni-vfx — Gemini Omni video-to-video (kie)

> **Paths** — `input/`, `analysis/`, `assets/`, `output/` are relative to the **active project** `projects/<slug>/` (the video being edited), not the repo root.

Transforms a real clip window while keeping the subject + lip-sync. Model: `gemini-omni-video`.

## Before spending — the gate
Omni is billed on submit. **Show the user the cost estimate and get a go.** First time on a fresh account, run `bash scripts/probe-omni.sh` once to learn the real `creditsConsumed`, then quote from that.

### Resolution — always the USER's choice (ask every generation)
Before each Omni submit, **let the user pick the resolution** — `720p` · `1080p` · Don't silently default. Present the trade-off and a recommendation, then use whatever they choose:
- `720p` 
- `1080p` 

**Aspect ratio is NOT a user choice** — it's auto-detected from the source (`ffprobe`) and must be `16:9` or `9:16` (map anything else to the nearest and say so). Always match the input video.

## Inputs (from the beat)
- The cut segment `beats/<seg>/src.mp4` (made by `assemble` — a ≤10s window).
- The exact-seconds prompt from `craft-prompt` (`beats/<seg>/prompt.txt`).
- Optional ≤7 reference images (from `assets/refs/` — mascots, products, cards, logos).

## Build the body + run
1. Host the source clip + refs: `URL=$(bash scripts/kie.sh upload beats/<seg>/src.mp4)`. *(Verify the upload endpoint on your kie account; if it differs, upload via any public host and paste the URL.)*
2. Write `beats/<seg>/omni.json`:
```json
{ "model":"gemini-omni-video",
  "input":{
    "prompt":"TASK: ...\nSCENE CONSTRAINTS: ...\nAUDIO: ...\nTIMING SEQUENCE: - [Xs-Ys]: ...",
    "video_list":[{ "url":"<hosted src url>", "start":0, "ends":8 }],
    "image_urls":["<ref url>"],
    "aspect_ratio":"16:9",
    "resolution":"1080p" } }
```
   - `prompt`: the exact-seconds prompt from `beats/<seg>/prompt.txt` (see `prompts/_formula.md` §A).
   - `video_list`: 1 clip, window `ends-start ≤ 10`. `duration` takes even-number buckets ("4"/"6"/"8") and is ignored when a video is given.
   - Quota: `images + videos×2 + character_ids ≤ 7`.
   - `resolution`: `720p` (cheap probe) · `1080p` (edit-ready) · `4k` — the USER's choice (see above).
3. `TID=$(bash scripts/kie.sh submit beats/<seg>/omni.json)` → taskId persisted to `omni.taskid`.
4. `bash scripts/kie.sh wait "$TID"` → the result URL → `kie.sh download <url> beats/<seg>/out-<res>.mp4`.
5. Record `creditsConsumed` into `beats/<seg>/.gen.json`. Set beat status → 👀 review.

### ⏳ How to WAIT (mandatory — do not freelance polling)
The generation is async and can take minutes. **Submit once, then hand off to a single `kie.sh wait` running in the background** — it polls every 15s and returns only the result URL (or FAIL). Then go quiet.
- **Do NOT** hand-roll a `kie_get` / `recordInfo` loop in the conversation, and **do NOT** post a status message on each poll — that's noise. One "submitted, waiting" line, then nothing until it resolves or errors.
- **Never state elapsed time you didn't measure.** If you must mention duration, read it from a real clock, or don't mention it.
- The harness re-invokes you when the background `wait` finishes — that's your signal to download + report. Nothing else needs saying in between.
- Cost is billed on submit; a live taskId is money already spent — never resubmit it, just keep waiting.

## ⚠️ Audio — Omni ALWAYS regenerates it (the #1 gotcha)
Omni is a video+audio generative model: it **replaces the speaker's real voice with a synthetic AI voiceover**, and if you feed it a silent clip it invents one. Two rules:
1. Feed the source **with its audio** (the `assemble` cut keeps it).
2. **Never ship Omni's audio.** After the clip lands, `assemble` re-lays the **original** audio over the transformed video (timing matches) → `out-voiced.mp4`. That's what keeps the real voice.

## Known failure modes (tell the user, re-craft don't brute-force)
- **Character insertion works — direct it.** With a clear reference image + explicit placement ("crawls from behind ONTO his shoulder, perches, wobbles") Omni lands a character on the right spot and reacts to a gesture (proven repeatedly with the fluffy mascot). Give it a concrete placement + a trigger and it holds. A good 3D reference makes the character match (fluffy plush ref → fluffy plush in-scene).
- **Wrong thing changed / environment drifted** → the CHANGE block named more than one effect, or PRESERVE was too thin. Split the beat / fence harder.
- **Lip-sync broke** → PRESERVE didn't name "exact mouth movements and timing". Add it.
- **Garbled text** → legible text is Omni's weak spot (short wordmarks land best; long/small text can garble). Keep the words SHORT and describe them concretely ("a glowing wordmark reading GOOGLE OMNI"). **TEXT TRAP:** never put an action verb or the phrase "on-screen text" next to the quoted words — "power on an on-screen text wordmark" leaked the word POWER onto the frame. Say the wordmark "appears / glows brighter" instead. If a specific word still comes back garbled, re-craft it, or fall back to a `graphic-design` PNG for just that word.
- **Rotation repeats the wrong face past ~180°** → keep the rotation partial, or use a still.

## Then
**GATE 2** — the user watches `out.mp4`. On approval, `assemble` splices it back. Never auto-place.
