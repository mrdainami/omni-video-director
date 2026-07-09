---
name: craft-prompt
description: Turn an approved beat into the exact generation prompt — an exact-seconds constraint prompt for Omni (VFX) or a role-map brief for GPT-Image-2 (graphic). The core value of the kit. Use after GATE 1, per beat.
---

# craft-prompt

The reason this kit beats prompting by hand. Read `prompts/_formula.md` first — it holds both grammars. Then for each approved beat:

## If `type: vfx` → Omni prompt (exact-seconds format)
Read `prompts/_formula.md` §A — it has the full five-block structure + a proven worked example. The prompt has five labelled blocks — **TASK · SCENE CONSTRAINTS · AUDIO · TIMING SEQUENCE · OUTPUT REQUIREMENT** — and effects are pinned to **exact clip-relative seconds** from `analysis/words.json`. Then:
1. Pick the closest recipe in `prompts/recipes/` (product-swap, material-morph, set-transform, self-restyle, holograms-vfx, logo-wrap, physics-hook, **vfx-sequence-with-character**). Adapt it.
2. **TASK** — one line naming the edit ("Apply graphic overlays…", "Apply visual transformations…", "Composite animated 3D plush characters…").
3. **SCENE CONSTRAINTS** — "single continuous shot, no scene cuts" + the do-not-change list: face, *exact mouth movements*, expressions, clothing, room, lighting, camera framing, the foreground RGB microphone, plus any object whose shape must stay. References: attach any inserted character/object/logo as `image_urls` (≤7 real PNGs) and say "matching [Image N]"; things already in the shot (bottle→glass) need none.
4. **AUDIO** — "Preserve the native source audio track and voiceover identically…" (real audio is re-laid at assembly regardless; submit the unmuted source, never mute).
5. **TIMING SEQUENCE** — one bullet per beat with **exact clip-relative seconds** read from `words.json` (subtract the segment's in-point): `- [Xs-Ys]: On the words "<quote>" (spoken A.AA-B.BBs), <event>, anchored to his real motion ("as he raises his hand and points")`. Describe events + materials/optics, not adjectives. Many temporally-separated beats in one gen is fine; simultaneous changes are riskier.
6. **OUTPUT REQUIREMENT** — where relevant, "final frame clean / 100% source fidelity."
7. **TEXT TRAP.** Omni paints short wordmarks, but **never put an action verb or "on-screen text" next to the quoted words** — "power on an on-screen text wordmark" leaked "POWER" onto the frame. Say the wordmark "**appears** / **glows brighter**" instead. Long/small text still garbles — fall back to a `graphic-design` PNG composited with ffmpeg.

## If `type: graphic` → GPT-Image-2 role-map brief
1. Use the role-map sections from `_formula.md` (REFERENCE ROLE MAPPING / COMPOSITION / SUBJECT / ENVIRONMENT+STYLE / TEXT RENDERING / QUALITY).
2. Quote every on-screen word **verbatim** in the TEXT section with placement + colour.
3. List the reference images (logos as real PNGs, "use exactly, do not redraw"), ≤16.
4. Set aspect = the input video's aspect.

## Confirm it's the one that lands
Before writing it back, sanity-check against the recipe's "known failure" notes (e.g. Omni rotation past 180°, text garbling). Write the finished prompt into the beat's `prompt` cell in `beat-plan.md`, status → ✍️ prompted. **You propose; the user directs.** No generation here — that's the next skill, after the user confirms.
