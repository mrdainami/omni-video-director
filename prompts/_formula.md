# The prompt formula

The single reason this kit beats prompting by hand: a **repeatable prompt grammar** so the models behave. Two grammars — one per model.

---

## A. Gemini Omni — video-to-video (exact-seconds format)

Omni transforms footage you already shot. It will change the *wrong* thing or break lip-sync unless you fence it. The winning structure is five labelled blocks, and the effects are anchored to **exact clip-relative seconds** pulled from `analysis/words.json` (Whisper word timings). Timestamps beat narrative ("as he says…"): they hold lip-sync and land effects on-beat, and they keep Omni *compositing* onto the real footage instead of re-generating (and drifting) the whole frame.

```
TASK: one line naming the edit — "Apply graphic overlays…", "Apply visual transformations…",
  "Composite animated 3D plush characters…".

SCENE CONSTRAINTS: "Render in a single continuous shot with no scene cuts." + the do-not-change
  list: the man, his real face, exact mouth movements, expressions, clothing, the background room,
  lighting, camera framing, and the foreground RGB microphone. Name any object whose shape must
  stay. "The ONLY additions are …" when compositing new elements.

AUDIO: "Preserve the native source audio track and voiceover identically with zero modifications
  or artificial generation." (Omni still emits a synthetic voice — the real audio is re-laid at
  assembly regardless; this line just reduces how hard it fights you.)

TIMING SEQUENCE (times are exact, synced to the source speech): one bullet per beat —
  - [Xs-Ys]: On the words "<quote>" (spoken A.AA-B.BBs), <event>, anchored to his real motion
    ("as he raises his hand and points"). Describe materials/optics + how it catches the existing
    light. Say where it sits relative to his body.
  All times are CLIP-RELATIVE (each cropped segment starts at 0) — subtract the segment's start
  offset from the absolute word timings.

OUTPUT REQUIREMENT (when relevant): "The final frame must be entirely clean of transient graphics,
  returning to 100% pixel-fidelity matching the source video."
```



### Rules (all proven on real clips)

1. **Exact seconds, clip-relative.** Read the beat's words from `words.json`, subtract the segment's in-point, and write real timecodes (`[3.1s-4.2s]`, `spoken 3.24-3.58s`). This is the single biggest quality lever — it locks lip-sync and lands effects on the word.
2. **Anchor to word AND motion.** "On the word 'graphics', as he raises his hand and points, the chart appears above his fingertips." The motion anchor makes the composite track his body.
3. **Many beats in one gen is fine** — each needs its own timecode window. Temporally-separated beats are reliable; simultaneous changes work but are riskier.
4. **References insert characters/objects.** Put the mascot/product/logo in `image_urls` (≤7) and say "matching [Image N]" / "looks EXACTLY like [Image N]." Things already in the shot (bottle → glass) need no reference — they're transforms of what's there.
5. **SCENE CONSTRAINTS is a fence, not a wish.** Name *face + exact mouth movements + expressions* every time the subject is on screen, or the mouth desyncs.
6. **Describe events, not adjectives.** "the card catches the key light as it pops up" beats "smooth, cinematic" (renders dead).
7. **Limits:** source window ≤10s, aspect 16:9 or 9:16, `duration` takes even-number buckets ("4"/"6"/"8"), `1080p` or 720p for the aspect ratio. Submit the ORIGINAL (unmuted) source so Omni locks onto the real voice/timing — never mute. **Omni regenerates audio → always re-lay your original audio at assembly.**



### Worked example — PROVEN (seg1: wordmark → timeline → hand-anchored graphics, one 4.36s gen)

```
TASK: Video-to-Video Edit. Apply graphic overlays to the provided source video based on the reference images.

SCENE CONSTRAINTS: Render in a single continuous shot with no scene cuts. Keep everything else the
same. Do not change or re-render the man, his real face, exact mouth movements, expressions, clothing,
background room, lighting, or the foreground RGB microphone.

AUDIO: Preserve the native source audio track and voiceover identically with zero modifications or
artificial generation.

TIMING & GRAPHICS SEQUENCE (times are exact, synced to the source speech):
- [0.0s-1.4s]: On the words "Google Omni" (spoken 0.0-0.56s), a glowing cyan-to-white neon wordmark
  reading "GOOGLE OMNI" appears on a layer BEHIND his head and shoulders, glowing brighter with a soft
  bloom and casting a faint cyan spill on his shoulders without covering his face, then fades out by 1.4s.
- [1.34s-2.2s]: On the words "editing forever" (spoken 1.34-2.10s), insert an animated editing-timeline
  strip matching [Image 2] across the lower-third, playhead scrubbing left-to-right, then fade out by 2.4s.
- [3.1s-4.2s]: On the word "graphics" (spoken 3.24-3.58s), as he raises his hand and points, two soft
  puffy 3D graphics matching [Image 3] appear DIRECTLY ABOVE his pointing hand/fingers — a rising bar
  chart and a "10x FASTER / VIDEO EDITING" card — bob, then drift up out of the top of frame before the end.

OUTPUT REQUIREMENT: The final frame must be entirely clean of transient graphics, returning to 100%
pixel-fidelity matching the source video.
```

→ Submit with `image_urls:[<ref urls>]`, `video_list:[{url,start,ends}]`, aspect 16:9, `resolution:"1080p"`, `duration:"4"`.

### Blank skeleton to fill

```
TASK: <one line — overlay / transform / composite>.
SCENE CONSTRAINTS: Render in a single continuous shot with no scene cuts. Do not change or re-render
  the man, his real face, exact mouth movements, expressions, clothing, the room, lighting, camera
  framing, or the foreground RGB microphone. <name any object whose shape must stay>.
AUDIO: Preserve the native source audio track and voiceover identically with zero modifications or
  artificial generation.
TIMING SEQUENCE (times are exact, synced to the source speech):
- [Xs-Ys]: On the words "<quote>" (spoken A.AA-B.BBs), <event + materials/optics + placement on body>.
- [Xs-Ys]: On the words "<quote>" (spoken A.AA-B.BBs), <event>.
OUTPUT REQUIREMENT: <clean final frame / 100% source fidelity — when relevant>.
```

(All timecodes CLIP-RELATIVE — subtract the segment's start offset from the `words.json` timings.)

---



## B. GPT-Image-2 — the ROLE-MAP brief (still graphics)

GPT-Image-2 takes up to **16 reference images** and renders **real, legible text** — the opposite of Omni. Structured sections, not a prose blob:

```
=== REFERENCE ROLE MAPPING ===
- [Image 1]: primary subject / identity — match exactly
- [Image 2+]: graphic assets (logos, product, elements) — "use exactly, do not redraw"
=== COMPOSITION & BLOCKING ===   where each element sits; sizes
=== SUBJECT INSTRUCTIONS ===     what the subject is/does
=== ENVIRONMENT & STYLE ===      background, palette (hex), graphic language
=== TEXT RENDERING CONSTRAINTS ===  each caption VERBATIM in quotes + placement + colour
=== FINAL QUALITY DIRECTIVES ===  output type; "use references exactly"
```

**Rules:**

- **Text:** quote it exactly in the TEXT section with placement + colour. To exclude: "no text, no captions, no logos."
- **Logos:** never model-drawn — pass a real transparent PNG as a numbered image, "use Image N exactly, keep shape + colour, do not redraw."
- **Reference order is preserved** — address images by array position (`Image 1…N`).
- **Style is fully promptable** — same shape, any material ("glossy vinyl toy" vs "soft fluffy plush" vs "claymation"): say it.
- Match the **input video's aspect** so the graphic drops in clean. Default `2K` (4K for a hero card).

*(This grammar is the proven Dainami still recipe. Full identity-lock / face-crop rules live in the source project; for a generic subject the role-map above is enough.)*