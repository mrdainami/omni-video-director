---
name: omni-vfx
description: Generate the VFX version of a beat's segment with Gemini Omni (video-to-video) on kie. Submit, poll, download. Use for type=vfx beats after the prompt is crafted and the user approves the spend.
---

# omni-vfx — Gemini Omni video-to-video (kie)

> **Paths** — `input/`, `analysis/`, `assets/`, `output/` are relative to the **active project** `projects/<slug>/` (the video being edited), not the repo root.

Transforms a real clip window while keeping the subject + lip-sync. Model: `gemini-omni-video`.

## Before spending — the gate
Omni is billed on submit. **Get the user's go before submitting.**

### Resolution — always the USER's choice (ask every generation)
Before generating, ask plainly: **"720p or 1080p?"** — nothing about which is cheaper, credit amounts, or a recommendation. Just the choice; use whatever they pick.

**Aspect ratio is NOT a user choice** — it's auto-detected from the source (`ffprobe`) and must be `16:9` or `9:16` (map anything else to the nearest and say so). Always match the input video.

**Segment sizing — cut to an EXACT even-second bucket (the sync rule):** one generation per full segment carrying 2–3 timed edits — never one gen per single effect (see the segmentation rule in the root `CLAUDE.md`). **Cut every segment to an EXACT `4` / `6` / `8` / `10` s length** (whichever bucket fully contains its action), and submit `duration` set to that same bucket. Proven on real clips: Omni returns the output at the `duration` bucket length — feed it a source of the *same* length and the output comes back matching (e.g. 10.0s→10.005s), so **lip-sync holds natively and NO time-lock/`setpts` is needed** — re-lay the original audio directly. Feed a fractional-length source (8.67s) and Omni floors it to the bucket (8.0s), compressing the video and desyncing the re-laid audio. So: pick the bucket first, cut the source to exactly that many seconds (snap the window to still cover the whole moment), submit with that `duration`.

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
    "duration":"8",
    "aspect_ratio":"16:9",
    "resolution":"1080p" } }
```
   - `prompt`: the exact-seconds prompt from `beats/<seg>/prompt.txt` (see `prompts/_formula.md` §A).
   - `video_list`: 1 clip; `ends` = the source length = the SAME even bucket as `duration` (`ends-start` ∈ {4,6,8,10}, ≤10).
   - `duration`: **REQUIRED**, and set to the bucket matching the exact source length (`"4"`/`"6"`/`"8"`/`"10"`). Do NOT omit it and do NOT let it differ from the source length — a mismatch makes Omni re-time the clip and desyncs the audio (see the sync rule above).
   - Quota: `images + videos×2 + character_ids ≤ 7`.
   - `resolution`: `720p` · `1080p` · `4k` — the USER's choice (ask "720p or 1080p?"; see above).
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
