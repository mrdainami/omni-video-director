# Run checklist — this video

The gated process for every video (full detail in the repo-root `CLAUDE.md`). Work top to bottom; the user reviews at every GATE. Nothing is generated before GATE 3.

## Segmentation rule (the one that matters)
- Each segment is a **FULL, uninterrupted window up to 10s** covering the whole moment an edit belongs to — **never cut mid-action or mid-sentence.**
- Pack **2–3 edits per segment** (3 is fine when it fits).
- **One Omni generation per segment** — 168 cr flat whether it's 2s or 10s. Cover the video in as *few* ≤10s segments as possible. Never one gen per single effect.

## Sync & safety — DO NOT SKIP (full detail: `prompts/SYNC-AND-SAFETY.md`)
These prevent the two credit-wasting failures: desynced audio and Google safety rejections.
- [ ] **Cut every segment to an EXACT even bucket — 4 / 6 / 8 / 10 s** (`ffmpeg -ss <start> -i in.mp4 -t <bucket> …`). Omni returns the output at the bucket length, so an exact source = native sync, no time-lock. A fractional source (8.67s) gets floored → desync.
- [ ] **Submit `duration` = that same bucket** (it's REQUIRED; never omit, never let it differ from the cut length).
- [ ] **Prompt text never contains the words "clip-relative" or "rel," and never pins an end to a fractional length.** Header stays exactly `(times are exact, synced to the source speech)`; end persistent effects with "to end." (Leaking these re-times the whole clip → desync.)
- [ ] **Re-lay the original audio directly** — no `setpts`/time-lock when cut to an exact bucket.
- [ ] **On a Google safety flag: STOP and ask** (retry vs. change prompt). Never silence the audio, never auto-regen.

## Steps
- [ ] **1. Ask where to edit.** "Do you have spots in mind for edits/cuts, or should I decide?" — before analyzing.
- [ ] **2. Analyze + transcribe** (`analyze-video` + Whisper `words.json`). Shape segments around the user's spots + the segmentation rule.
- [ ] **3. Build `analysis/beat-plan.md`** — full ≤10s segments, 2–3 edits each, aspect recorded.
- [ ] **GATE 1 — approve the plan.**
- [ ] **4. Cut segments** (`assemble` → `beats/<seg>/src.mp4`) **and craft prompts** (`craft-prompt` → `beats/<seg>/prompt.txt`). **Then STOP.**
- [ ] **GATE 2 — review cuts + prompts.** Ask: "Any graphics to add or change anywhere?"
- [ ] **5. Generate ALL graphics first** (supplied PNGs or `graphic-design` → `assets/refs/`). User confirms **every** graphic.
- [ ] **GATE 3 — generate parts.** Ask **"720p or 1080p?"** → get the go → `omni-vfx` per segment (exact even bucket + matching `duration`).
- [ ] **GATE 4 — watch, then stitch.** Approve each clip → `assemble` places each at its true in-point, concats with the untouched footage, re-lays original audio → `output/`. (Exact-even cuts already match length — no time-lock.)
