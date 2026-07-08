---
name: craft-prompt
description: Turn an approved beat into the exact generation prompt — a two-part constraint prompt for Omni (VFX) or a role-map brief for GPT-Image-2 (graphic). The core value of the kit. Use after GATE 1, per beat.
---

# craft-prompt

The reason this kit beats prompting by hand. Read `prompts/_formula.md` first — it holds both grammars. Then for each approved beat:

## If `type: vfx` → Omni prompt (REFERENCES + PRESERVE + CHANGE)
Read `prompts/_formula.md` §A — it has the full structure + a proven worked example. Then:
1. Pick the closest recipe in `prompts/recipes/` (product-swap, material-morph, set-transform, self-restyle, holograms-vfx, logo-wrap, physics-hook, **vfx-sequence-with-character**). Adapt it.
2. **REFERENCES** — if the beat inserts a character/object/logo (mascot, product), attach it as `image_urls` (≤7 real PNGs) and say "looks EXACTLY like the reference image." Things already in the shot (bottle→glass, face→beard) need no reference.
3. **PRESERVE** — name only what must survive. Subject on screen → always *face + exact mouth movements + timing*, plus wardrobe, background, lighting, camera, and any object whose shape must stay.
4. **CHANGE** — one beat, OR a **numbered timed sequence** if several things happen across this window ("(1) EARLY … (2) LATER, as he tilts …"). Multiple temporally-separated beats in one gen is fine (proven); simultaneous changes work but are riskier. Describe events + materials/optics, not adjectives.
5. **No legible text via Omni** — route text/cards to `graphic-design` or a HyperFrames overlay.

## If `type: graphic` → GPT-Image-2 role-map brief
1. Use the role-map sections from `_formula.md` (REFERENCE ROLE MAPPING / COMPOSITION / SUBJECT / ENVIRONMENT+STYLE / TEXT RENDERING / QUALITY).
2. Quote every on-screen word **verbatim** in the TEXT section with placement + colour.
3. List the reference images (logos as real PNGs, "use exactly, do not redraw"), ≤16.
4. Set aspect = the input video's aspect.

## Confirm it's the one that lands
Before writing it back, sanity-check against the recipe's "known failure" notes (e.g. Omni rotation past 180°, text garbling). Write the finished prompt into the beat's `prompt` cell in `beat-plan.md`, status → ✍️ prompted. **You propose; the user directs.** No generation here — that's the next skill, after the user confirms.
