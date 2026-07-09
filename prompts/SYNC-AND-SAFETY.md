# Sync & safety — the rules that stop off-sync and Google rejections

Hard-won on real Omni runs. Read before cutting and before submitting. These five prevent the two failure modes that waste credits: **desynced audio** and **Google safety rejections**.

---

## 1. Cut to an EXACT even-second bucket (native sync)
Omni returns every generation at its `duration` bucket length — **4 / 6 / 8 / 10 s**. So:
- Pick the **smallest bucket that fully covers the moment**, snap the in-point so the whole action stays inside.
- Cut the source to **exactly** that many seconds — cut by duration, not by an out-point:
  ```bash
  ffmpeg -ss <start> -i input/<clip>.mp4 -t <bucket>   # bucket ∈ 4|6|8|10
    -c:v libx264 -r 30 -g 30 -keyint_min 30 -pix_fmt yuv420p -c:a aac -movflags +faststart \
    beats/<seg>/src.mp4
  ```
- Submit `duration` = that same bucket, `ends` = the same length.
- **Result:** output length == source length → lip-sync holds natively. Re-lay the original audio **directly — no `setpts`, no time-lock.**
- **Anti-rule:** a fractional source (8.67s) gets floored to the bucket (8.0s) → video compressed → re-laid audio drifts. Proven: our first round desynced all three this way.

## 2. Keep internal notes OUT of the prompt text (this is what desynced every clip)
The single biggest cause of whole-clip re-timing in our runs was leaking computation notes into the prompt:
- The header stays **exactly** `(times are exact, synced to the source speech)`.
- **NEVER** type the words `clip-relative` or `rel` into the prompt. "Clip-relative" is only a *math step* — subtract the segment's in-point from the `words.json` word times — it is not prompt text.
- **NEVER** pin an effect's end to a fractional clip length (`[1.5s-8.67s]`). Use clean ranges, and end persistent effects with **"to end."**
- Both of the above re-base Omni's time grid → it re-generates/re-times the whole frame instead of compositing → the mouth drifts off the audio.

## 3. The proven prompt structure (five blocks)
```
TASK: <one line — overlay / transform / composite>.
SCENE CONSTRAINTS: Render in a single continuous shot with no scene cuts. Do not change or re-render
  the man, his real face, exact mouth movements, expressions, <clothing/room/hands as apt>, camera
  framing, or the foreground RGB microphone. <name any object whose shape must stay>.
AUDIO: Preserve the native source audio track and voiceover identically with zero modifications or
  artificial generation.
<TIMING & GRAPHICS | TRANSFORMATION | CHARACTER> SEQUENCE (times are exact, synced to the source speech):
- [Xs-Ys]: On the words "<quote>" (spoken A.AA-B.BBs), <event + materials/optics + placement on body>.
- ...
OUTPUT REQUIREMENT: <clean final frame / 100% source fidelity — when relevant>.
```
- Effect-specific SEQUENCE header (graphics → `TIMING & GRAPHICS`, restyle/material → `TRANSFORMATION`, character insert → `CHARACTER`).
- Plain spoken tags: `(spoken 0.19-1.47s)` — no "rel".
- **For transforms, add a REVERT-to-source beat between effects** and say "HOLD steadily so it is easy to see." Keeping most of the clip at source fidelity is what holds lip-sync.
- Fence hard: always name *face + exact mouth movements + the RGB microphone* in SCENE CONSTRAINTS.
- Short on-screen words only (Omni garbles long text) — say the wordmark "appears / glows brighter", never put an action verb next to the quoted words (the TEXT TRAP).

## 4. `duration` is REQUIRED and must equal the source length
Always include `duration` in the submit body, set to the exact bucket. Omitting it (or letting it differ from the cut length) makes Omni re-time the clip. `duration` matching the source length is part of the sync fix, not optional.

## 5. Google safety flag → STOP and ask (never silence audio)
If an Omni gen fails on a Google safety/privacy flag (it flags the uploaded **audio**):
- Do **NOT** auto-resubmit with muted/silenced audio — silent audio desyncs the output and defeats feeding the real voice.
- Do **NOT** silently regenerate.
- **Stop and ask the user:** (a) retry as-is, or (b) change the prompt. A plain retry sometimes clears a transient flag; the user decides.

## 6. Assembly hygiene
- Omni outputs at 720p/1080p **@ 24fps**; the source may be 1080p **@ 60fps** — normalize every piece (transformed segments + original-footage gaps) to one resolution + fps before concat.
- Place each transformed segment back at its **true source in-point**; fill un-generated stretches with the original footage.
- Lay the **original full audio** over the whole timeline once (Omni's per-segment audio is synthetic — discard it).
