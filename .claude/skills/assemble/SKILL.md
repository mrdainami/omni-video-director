---
name: assemble
description: Cut a beat's segment out of the source, and drop the generated asset back into the cut — built on HyperFrames (with ffmpeg for the raw trim). Use to extract src.mp4 before generation, and to place the approved asset after GATE 2.
---

# assemble — cut + place (HyperFrames)

Two jobs, one skill: **cut** the segment before generating, **place** the asset after the user approves.

## Cut (before generation)
Extract the beat window into `assets/<beat>/src.mp4` (Omni needs a ≤10s clip):
```bash
ffmpeg -i input/<clip>.mp4 -ss <start_sec> -to <end_sec> \
  -c:v libx264 -r 30 -g 30 -keyint_min 30 -pix_fmt yuv420p -movflags +faststart \
  assets/<beat>/src.mp4
```
Dense keyframes (`-g 30`) matter — sparse keyframes make the face freeze on seek downstream.

## Place (after GATE 2)
Drop the approved asset back onto the timeline. Two cases:
- **vfx (out.mp4)** — replaces the original window: the transformed segment takes the same in/out.
- **graphic (out.png)** — overlays on top of the playing video for the beat's duration (full-screen or corner).

Built on **HyperFrames** (deterministic HTML → MP4). Minimal composition: the source video on a base track, each asset as a `class="clip"` with `data-start` / `data-duration` / `data-track-index` (no two clips share a track). Then render.

```bash
# one-time: npx hyperframes init  (creates the HyperFrames project)
# author index.html: base <video> track + overlay clips at their timestamps
npx hyperframes render . -o /tmp/avd/out.mp4     # render to /tmp, never in a synced folder
cp /tmp/avd/out.mp4 output/<clip>-final.mp4
```

> ⚠️ **Render to `/tmp`, not into this repo if it's inside a synced folder** — HyperFrames writes thousands of temp frames; on Dropbox/iCloud that spikes RAM and can crash editors. Render in `/tmp`, copy only the MP4 back.

## Simplest path (if HyperFrames isn't set up yet)
For a quick proof, a plain ffmpeg overlay works for a graphic:
```bash
ffmpeg -i input/<clip>.mp4 -i assets/<beat>/out.png \
  -filter_complex "[0][1]overlay=enable='between(t,<start>,<end>)'" output/draft.mp4
```
HyperFrames is the upgrade for animated/branded overlays, captions, and multi-beat assembly.

## Status
On place, set the beat → ✅ placed in `beat-plan.md`. When all beats are placed, the final is in `output/`.
