---
name: craft-prompt
description: Turn an approved beat into the exact generation prompt — a two-part constraint prompt for Omni (VFX) or a role-map brief for GPT-Image-2 (graphic). The core value of the kit. Use after GATE 1, per beat.
---

# craft-prompt

The reason this kit beats prompting by hand. Read `prompts/_formula.md` first — it holds both grammars. Then for each approved beat:

## If `type: vfx` → Omni two-part prompt
1. Pick the closest recipe in `prompts/recipes/` (product-swap, material-morph, set-transform, self-restyle, holograms-vfx, logo-wrap, physics-hook). Adapt it — don't start blank.
2. Fill the skeleton:
   - **PRESERVE** — name only what must survive. If the subject is on screen, always include *face + exact mouth movements + timing*, plus wardrobe, background, lighting, camera.
   - **CHANGE** — the ONE targeted effect, with real materials/optics and how it catches the existing light.
3. **One effect per beat.** Two changes = drift. If the beat wants two things, split it into two beats.
4. If the beat needs a target texture/product/logo, note the reference image(s) to attach (≤7, real assets).

## If `type: graphic` → GPT-Image-2 role-map brief
1. Use the role-map sections from `_formula.md` (REFERENCE ROLE MAPPING / COMPOSITION / SUBJECT / ENVIRONMENT+STYLE / TEXT RENDERING / QUALITY).
2. Quote every on-screen word **verbatim** in the TEXT section with placement + colour.
3. List the reference images (logos as real PNGs, "use exactly, do not redraw"), ≤16.
4. Set aspect = the input video's aspect.

## Confirm it's the one that lands
Before writing it back, sanity-check against the recipe's "known failure" notes (e.g. Omni rotation past 180°, text garbling). Write the finished prompt into the beat's `prompt` cell in `beat-plan.md`, status → ✍️ prompted. **You propose; the user directs.** No generation here — that's the next skill, after the user confirms.
