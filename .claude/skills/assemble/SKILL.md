---
name: assemble
description: Cut a beat's segment out of the source, and drop the generated asset back into the cut — built on HyperFrames (with ffmpeg for the raw trim). Use to extract src.mp4 before generation, and to place the approved asset after GATE 2.
---

# assemble — cut + place (HyperFrames)

> **Paths** — `input/`, `analysis/`, `assets/`, `output/` are relative to the **active project** `projects/<slug>/` (the video being edited). `hf/` stays shared at the repo root; copy it into the project only when a custom overlay comp is needed.

Two jobs, one skill: **cut** the segment before generating, **place** the asset after the user approves.

## Cut (before generation)
Extract the beat window into `assets/<beat>/src.mp4` (Omni needs a ≤10s clip). **KEEP the audio** (`-c:a aac`, never `-an`) — we re-lay it after Omni:
```bash
ffmpeg -i input/<clip>.mp4 -ss <start_sec> -to <end_sec> \
  -c:v libx264 -r 30 -g 30 -keyint_min 30 -pix_fmt yuv420p -c:a aac -movflags +faststart \
  assets/<beat>/src.mp4
```
Dense keyframes (`-g 30`) matter — sparse keyframes make the face freeze on seek downstream.

> **Also keep the original audio around separately** — `ffmpeg -ss <start> -to <end> -i input/<clip>.mp4 -vn -c:a aac assets/<beat>/orig-audio.m4a` — you'll mux it back over the Omni output (next).

## Restore the real voice (right after an Omni clip lands) — REQUIRED for vfx
**Omni regenerates the audio track — it will replace the speaker's voice with a synthetic one.** Never ship Omni's audio. Because Omni preserves timing, the original audio lines up exactly, so re-lay it:
```bash
ffmpeg -i assets/<beat>/out.mp4 -i assets/<beat>/orig-audio.m4a \
  -map 0:v:0 -map 1:a:0 -c:v copy -c:a aac -shortest assets/<beat>/out-voiced.mp4
```
Use `out-voiced.mp4` as the beat's asset. (If the source window truly had no speech, Omni's audio can be dropped entirely instead.)

## Place (after GATE 2)
Drop the approved asset back onto the timeline. Two cases:
- **vfx (out.mp4)** — replaces the original window: the transformed segment takes the same in/out.
- **graphic (out.png)** — overlays on top of the playing video for the beat's duration (full-screen or corner).

Built on **HyperFrames** (deterministic HTML → MP4, seek-safe). The kit already has the project wired in **`hf/`**: `index.html` (a working composition template), `gsap.min.js` (bundled, offline), `kit.css` (brand tokens), `assets/` (drop clips/graphics here). No `init` needed.

### The contract (from `hf/index.html`)
- Root: `<div id="root" data-composition-id="main" data-start="0" data-duration="<sec>" data-width data-height>`.
- Every timed element: `class="clip"` + `data-start` + `data-duration` + `data-track-index`. **No two clips share a track at overlapping times.**
- **Base video** on track 0: `<video class="clip" src="assets/base.mp4" muted style="…object-fit:cover">`. The clip's **audio** goes on its own track: `<audio class="clip" data-track-index="5" data-volume="1" src="assets/base.mp4">`.
- **Animated overlays** (the reason we use HyperFrames — Omni/GPT-Image can't animate): a `class="clip"` div on its own track; animate it in the GSAP timeline. **Count-ups are seek-safe** via `gsap.to({v:0},{v:100,onUpdate:…})`. Never use `rAF` / `Date.now` / `Math.random`.

### Multi-beat assembly
- **A single Omni'd clip + graphics** → put the clip as the base, overlay each graphic at its `data-start`. (Proven: base beat + a `0→100%` count-up card.)
- **Stitch several transformed segments** → either (a) lay each transformed segment on track 0 back-to-back at its real in-point, or (b) ffmpeg-`concat` the segments into one base first, then overlay graphics in HF. (a) is cleaner for cross-fades.

### Render
```bash
npx hyperframes validate hf                       # optional: catches contract errors
npx hyperframes render hf -o /tmp/avd-hf/out.mp4 -q draft   # draft to check; drop -q for standard/high
cp /tmp/avd-hf/out.mp4 output/<clip>-final.mp4
```
Draft render of a 7s clip ≈ **5 seconds**. Bump quality for the final: `-q high`.

> ⚠️ **Render output to `/tmp`, not into a synced folder** — HyperFrames writes many temp frames; on Dropbox/iCloud that spikes RAM. Render to `/tmp`, copy only the MP4 back. (The kit lives on `~/Desktop`, which is fine to author in; keep render *output* in /tmp.)

## Quick ffmpeg fallback (static overlay only)
If you just need a static PNG on a clip (no animation), ffmpeg is fine:
```bash
ffmpeg -i input/<clip>.mp4 -i assets/<beat>/out.png \
  -filter_complex "[0][1]overlay=enable='between(t,<start>,<end>)'" output/draft.mp4
```
Use HyperFrames for anything animated (count-ups, mascot slide/swipe, transitions, captions).

## Status
On place, set the beat → ✅ placed in `beat-plan.md`. When all beats are placed, the final is in `output/`.
