---
name: analyze-video
description: Watch a video with Gemini 3.5 Flash (frames + audio) and produce a timestamped beat plan — the moments that want a b-roll or graphic. Writes analysis/beat-plan.md. Use at the start of a run.
---

# analyze-video

> **Paths** — `input/`, `analysis/`, `assets/`, `output/` are relative to the **active project** `projects/<slug>/` (the video being edited), not the repo root.

Turns the raw clip in `input/` into `analysis/beat-plan.md` — the source of truth for the whole run.

## Run it
1. `python3 scripts/analyze.py input/<clip>.mp4 > analysis/beats.json`
   - **Primary — audio-aware, one key:** Gemini 3.5 Flash via **OpenRouter** (`OPENROUTER_API_KEY`). The clip is downscaled + base64'd into the request, so it sees frames **AND hears the audio** — beats anchor to what's actually said. No native Gemini key, no file upload. *(Confirmed: it transcribes speech.)*
   - **Big videos (>~4 min):** the base64 gets large. Either downscale harder / chunk into segments, or use `scripts/analyze_native.sh` (native Gemini File API, needs `GEMINI_API_KEY`, handles up to ~1hr).
   - **No-audio ultralight fallback:** `python3 scripts/analyze_frames.py input/<clip>.mp4 2` (frames only, OpenRouter).
2. **Convert + write the plan.** Each beat comes back as `{start:"MM:SS", end:"MM:SS", beat_type, reason, suggestion}`. Convert MM:SS → seconds (`mm*60+ss`) and write `analysis/beat-plan.md` as the table below.
3. Also record the **input aspect**: `ffprobe -v error -select_streams v:0 -show_entries stream=width,height -of csv=p=0 input/<clip>.mp4` → note `16:9` or `9:16` (map anything else to nearest for Omni).

## beat-plan.md format
```
# Beat plan — <clip>   (aspect: 16:9 · duration: 12:34)

| # | start | end | type | what to add | why | prompt | status |
|---|-------|-----|------|-------------|-----|--------|--------|
| 1 | 00:07 | 00:11 | vfx | brand can swap | "our energy drink" | (craft-prompt fills) | 🔲 plan |
| 2 | 00:22 | 00:25 | graphic | 3-stat card | reels off 3 numbers | (craft-prompt fills) | 🔲 plan |
```
Status ladder: 🔲 plan → ✍️ prompted → 🎬 generating → 👀 review → ✅ placed.

## Reality (be honest)
- Gemini samples ~**1 FPS** → timestamps are **±1s**, great for beat-marking, blind to sub-second cuts. Nudge the in/out a touch when you cut.
- Long videos (>~50 min): the script fits default res; if it errors on context, add `media_resolution: low`.
- This step is **cheap** (cents). The expensive step is generation — that's gated later.

## Then
Show `beat-plan.md` to the user — **GATE 1**. They edit/cut/add beats. Only after approval does `craft-prompt` run.
