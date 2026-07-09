---
name: analyze-video
description: Read a video two ways — Gemini 3.5 Flash (frames + audio) for the beat plan, and Whisper (OpenRouter) for exact word timing. Writes analysis/beat-plan.md + analysis/words.json. Use at the start of a run.
---

# analyze-video

> **Paths** — `input/`, `analysis/`, `assets/`, `output/` are relative to the **active project** `projects/<slug>/` (the video being edited), not the repo root.

Turns the raw clip in `input/` into `analysis/beat-plan.md` + `analysis/words.json` — the source of truth for the whole run. **There are two reads, and they do different jobs:** Gemini finds *what/where/why*; Whisper gives *exact when*.

## Run it
1. **Read #1 — semantic beats (Gemini).** `python3 scripts/analyze.py input/<clip>.mp4 > analysis/beats.json`
   - **Audio-aware, one key:** Gemini 3.5 Flash via **OpenRouter** (`OPENROUTER_API_KEY`). The clip is downscaled + base64'd into the request, so it sees frames **AND hears the audio** — beats anchor to what's actually said. No native Gemini key, no file upload.
   - **Big videos (>~4 min):** the base64 gets large. Either downscale harder / chunk into segments, or use `scripts/analyze_native.sh` (native Gemini File API, needs `GEMINI_API_KEY`, handles up to ~1hr).
   - **No-audio ultralight fallback:** `python3 scripts/analyze_frames.py input/<clip>.mp4 2` (frames only, OpenRouter).
2. **Read #2 — exact word timing (Whisper).** `python3 scripts/transcribe.py input/<clip>.mp4` → `analysis/words.json`
   - OpenRouter **Whisper large-v3** (`OPENROUTER_API_KEY`), word-level timestamps to ~10ms. **This is where the correct timing comes from** — Gemini's ±1s timestamps drift and cut off sentences; Whisper's word-times let you place seams in the pauses *between* words and write exact-seconds prompts later.
   - Whisper mis-hears proper nouns ("Omni"→"only", "Claude"→"cloud") — ignore the spelling, the **timing** is what we use.
3. **Convert + write the plan.** Each Gemini beat comes back as `{start:"MM:SS", end:"MM:SS", beat_type, reason, suggestion}`. Convert MM:SS → seconds, then **snap each in/out to the nearest word boundary in `words.json`** so no cut lands mid-word. Write `analysis/beat-plan.md` as the table below.
4. Also record the **input aspect**: `ffprobe -v error -select_streams v:0 -show_entries stream=width,height -of csv=p=0 input/<clip>.mp4` → note `16:9` or `9:16` (map anything else to nearest for Omni).

## beat-plan.md format
**Group edits into full ≤10s SEGMENTS (2–3 edits each), one row per segment** — never one row/gen per single effect, and never cut a segment mid-action (see the segmentation rule in the root `CLAUDE.md`). Each segment = one Omni generation.
```
# Beat plan — <clip>   (aspect: 16:9 · duration: 12:34)

| seg | start | end | type | edits in this segment (2–3) | why | prompt | status |
|-----|-------|-----|------|-----------------------------|-----|--------|--------|
| 1 | 00:00 | 00:08 | vfx | (a) brand can swap · (b) 3-stat card floats in · (c) glowing wordmark | hook + product beat | (craft-prompt fills) | 🔲 plan |
| 2 | 00:12 | 00:20 | vfx | (a) set change · (b) mascot walks in | co-pilot beat | (craft-prompt fills) | 🔲 plan |
```
Each edit tagged with its own `type` (vfx | graphic) in the cell if they differ. Status ladder: 🔲 plan → ✍️ prompted → 🎬 generating → 👀 review → ✅ placed.

## Reality (be honest)
- Gemini samples ~**1 FPS** → its timestamps are **±1s** — good for *marking* beats, useless for exact cuts. **Always take the real in/out from `words.json` (Whisper), not from Gemini.**
- Long videos (>~50 min): the script fits default res; if it errors on context, add `media_resolution: low`.
- Both reads are **cheap** (cents). The expensive step is generation — that's gated later.

## Then
Show `beat-plan.md` to the user — **GATE 1**. They edit/cut/add beats. Only after approval does `craft-prompt` run (it pulls its exact timecodes from `words.json`).
