---
name: assemble
description: Cut a beat's segment out of the source, and drop the generated asset back into the cut — with ffmpeg (trim, audio re-lay, overlay, concat). Use to extract src.mp4 before generation, and to place the approved asset after GATE 2.
---

# assemble — cut + place (ffmpeg)

> **Paths** — `input/`, `analysis/`, `beats/`, `assets/`, `output/` are relative to the **active project** `projects/<slug>/` (the video being edited). Per-beat video work lives in `beats/<seg>/`; generated graphics live in `assets/refs/`.

Two jobs, one skill: **cut** the segment before generating, **place** the asset after the user approves. All of it is plain **ffmpeg**.

## Cut (before generation) — to an EXACT even-second bucket (the sync rule)
Extract the beat window into `beats/<seg>/src.mp4` at an **EXACT `4` / `6` / `8` / `10` s length** (pick the smallest bucket that fully covers the moment; snap the in-point so the whole action is inside). Cut by **duration** (`-t <bucket>`), not by an out-point, so the length lands exactly on the bucket. Omni is then submitted with `duration` = that same bucket, and returns the output at the same length → **sync holds natively, no time-lock needed** (see `omni-vfx`). **KEEP the audio** (`-c:a aac`, never `-an`) — we re-lay it after Omni:
```bash
ffmpeg -ss <start_sec> -i input/<clip>.mp4 -t <bucket>  # <bucket> ∈ 4 | 6 | 8 | 10
  -c:v libx264 -r 30 -g 30 -keyint_min 30 -pix_fmt yuv420p -c:a aac -movflags +faststart \
  beats/<seg>/src.mp4
```
Confirm it landed exactly on the bucket: `ffprobe -v error -show_entries format=duration -of default=nk=1:nw=1 beats/<seg>/src.mp4`. Record the true source in-point (`<start_sec>`) — the transformed segment is placed back at that in-point at assembly.
Dense keyframes (`-g 30`) matter — sparse keyframes make the face freeze on seek downstream.

> **Also keep the original audio around separately** — `ffmpeg -ss <start> -to <end> -i input/<clip>.mp4 -vn -c:a aac beats/<seg>/orig-audio.m4a` — you'll mux it back over the Omni output (next).

## Restore the real voice (right after an Omni clip lands) — REQUIRED for vfx
**Omni regenerates the audio track — it will replace the speaker's voice with a synthetic one.** Never ship Omni's audio. Because Omni preserves timing, the original audio lines up exactly, so re-lay it:
```bash
ffmpeg -i beats/<seg>/out.mp4 -i beats/<seg>/orig-audio.m4a \
  -map 0:v:0 -map 1:a:0 -c:v copy -c:a aac -shortest beats/<seg>/out-voiced.mp4
```
Use `out-voiced.mp4` as the beat's asset. (If the source window truly had no speech, Omni's audio can be dropped entirely instead.)

## Place (after GATE 2)
Drop the approved asset back onto the timeline. Two cases:

### A. vfx (out-voiced.mp4) — replaces the original window
The transformed segment takes the same in/out. Split the source around the window and concat:
```bash
# head: 0 → start, tail: end → duration  (scratch goes in beats/_scratch/, which is gitignored)
mkdir -p beats/_scratch
ffmpeg -i input/<clip>.mp4 -to <start> -c copy beats/_scratch/head.mp4
ffmpeg -i input/<clip>.mp4 -ss <end>  -c copy beats/_scratch/tail.mp4
printf "file '%s'\nfile '%s'\nfile '%s'\n" \
  "$PWD/beats/_scratch/head.mp4" "$PWD/beats/<seg>/out-voiced.mp4" "$PWD/beats/_scratch/tail.mp4" > beats/_scratch/list.txt
ffmpeg -f concat -safe 0 -i beats/_scratch/list.txt -c copy output/<clip>-final.mp4
```
If the segments differ in codec/size and concat stutters, re-encode instead of `-c copy`, or use the `xfade` path below for a clean cross-dissolve at the seams.

### B. graphic (`assets/refs/<name>.png`) — overlays on top of the playing video for the beat's window
The graphic-design output for this beat (a transparent PNG in `assets/refs/`) is composited over the base for `[start,end]`. Add a quick fade so it doesn't pop:
```bash
ffmpeg -i input/<clip>.mp4 -i assets/refs/<name>.png -filter_complex \
  "[1]format=rgba,fade=in:st=<start>:d=0.3:alpha=1,fade=out:st=<end-0.3>:d=0.3:alpha=1[g]; \
   [0][g]overlay=enable='between(t,<start>,<end>)':x=(W-w)/2:y=(H-h)/2" \
  -c:a copy output/<clip>-final.mp4
```
- Corner instead of centered: set `x=W-w-40:y=H-h-40`.
- Scale the graphic first if it's oversized: add `scale=iw*0.6:-1` in the `[1]` chain.

## Transitions & sweeps (beat 1b and any seam) — ffmpeg `xfade`
ffmpeg ships ~50 transitions (`fade`, `wipeleft`, `slideup`, `zoomin`, `dissolve`, `circleopen`…). Cross between two clips:
```bash
ffmpeg -i A.mp4 -i B.mp4 -filter_complex \
  "[0][1]xfade=transition=zoomin:duration=0.5:offset=<A_dur-0.5>,format=yuv420p" out.mp4
```
Use this for the "editing effect" sweep and for smoothing the seams where a transformed segment meets the untouched footage.

## Stitch several transformed segments
Lay each transformed segment back at its real in-point (case A per beat), left to right, working through the beats in order — or, if many, re-encode all pieces to one common format and `concat`, then overlay the graphics (case B) last. `xfade` at the joins keeps cuts from jarring.

## Notes
- **Can't matte cleanly with ffmpeg** — you can't key the subject out to put a graphic *behind* them. Options: composite the graphic *in front* (case B), or add a kie background-removal step if "behind" is essential.
- **Animated overlays** (bouncy slide-ins, count-ups) are painful in pure ffmpeg. Prefer generating motion *inside* Omni, or use a simple fade (case B). Fancy kinetic graphics are out of scope for the ffmpeg-only kit.
- Render straight to `output/` — ffmpeg streams, so no temp-frame blowup.

## Status
On place, set the beat → ✅ placed in `beat-plan.md`. When all beats are placed, the final is in `output/`.
