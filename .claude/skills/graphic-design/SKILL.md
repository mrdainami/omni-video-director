---
name: graphic-design
description: Generate an on-screen graphic (infographic, stat card, title, logo lockup) with GPT-Image-2 on kie — up to 16 references, real legible text. Use for type=graphic beats after the brief is crafted and the user approves the spend.
---

# graphic-design — GPT-Image-2 stills (kie)

For anything with real text or exact logos — the things Omni garbles. Model: `gpt-image-2-image-to-image` (or `-text-to-image` with no refs).

## Before spending — the gate
Billed on submit. Show the estimate, get a go. (GPT-Image-2 ≈ a few credits per still; the exact figure prints as `creditsConsumed`.)

## Inputs (from the beat)
- The role-map brief from `craft-prompt`.
- Reference images (logos as real transparent PNGs, product shots, style refs), ≤16.
- Aspect = the input video's aspect.

## Build the body + run
1. Host each reference: `URL=$(bash scripts/kie.sh upload <ref.png>)`.
2. Write `assets/<beat>/graphic.json`:
```json
{ "model":"gpt-image-2-image-to-image",
  "input":{
    "prompt":"=== REFERENCE ROLE MAPPING === ...\n=== TEXT RENDERING CONSTRAINTS === ...",
    "input_urls":["<ref url>","<ref url>"],
    "aspect_ratio":"16:9",
    "resolution":"2K" } }
```
   - `input_urls`: up to **16** references (this is why we use GPT-Image-2 — many refs).
   - `resolution`: `1K` iterate · `2K` default · `4K` hero (1:1 can't 4K).
   - No refs? use `gpt-image-2-text-to-image` (drop `input_urls`).
3. `TID=$(bash scripts/kie.sh submit assets/<beat>/graphic.json)` → `wait` → `download` to `assets/<beat>/out.png`.
   - GPT-Image-2's kie endpoint sometimes throws a transient `500` — just resubmit (a failed job is 0 credits). 4K queues slower; poll patiently.
4. Record `creditsConsumed`. Status → 👀 review.

## Text + logos (non-negotiable)
- Every word quoted **verbatim** in the TEXT section with placement + colour.
- Logos passed as numbered images, "use Image N exactly, do not redraw" — never model-drawn.

## Then
**GATE 2** — user reviews `out.png`. On approval, `assemble` overlays it at the beat's timestamp.
