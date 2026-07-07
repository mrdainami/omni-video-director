# The prompt formula

The single reason this kit beats prompting by hand: a **repeatable prompt grammar** so the models behave. Two grammars — one per model.

---

## A. Gemini Omni — the TWO-PART CONSTRAINT prompt (video-to-video)

Omni will happily change your whole shot — swap the wrong object, restyle the room, break lip-sync — unless you fence it. Every Omni prompt is two explicit blocks:

```
PRESERVE (do not change): <only what MUST survive — the person's face and exact
lip movements and timing, their clothing, the room/background, the lighting and
colour grade, the camera framing and motion>. Keep everything not named below
identical to the source footage.

CHANGE (one targeted effect): <the single transformation, described with real
optics/materials/physics>.
```

**Rules (learned the hard way):**
1. **ONE effect per generation.** Two changes → the environment drifts and the wrong thing swaps. Chain effects across passes, never in one prompt.
2. **The PRESERVE list is a fence, not a wish.** Whenever the subject is on screen, name *face + lip-sync + timing* every time, or the mouth desyncs.
3. **No real text / fine branding via Omni** — it garbles small type. Large flat artwork on a slowly rotating surface *sometimes* works (rotation past ~180° can repeat the wrong face). Real text, logos, infographics → `graphic-design` (GPT-Image-2) or a HyperFrames overlay at assembly.
4. **Describe events, not adjectives.** "the can catches the key light as he turns it" beats "smooth, stable, cinematic" (which renders dead).
5. **Source window ≤ 10s**, ≤ 30s file. Aspect 16:9 or 9:16 only. Default `1080p` for edit-ready (720p is cheaper for probing).

**Skeleton to fill:**
```
PRESERVE (do not change): the man's face, his exact mouth movements and timing, his
[wardrobe], the [room] behind him, the existing lighting and colour, and the camera's
[framing/motion]. Everything not listed below stays identical to the source.
CHANGE (one effect): [the single transformation, with materials + optics + how it
catches the existing light].
```

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
- Match the **input video's aspect** so the graphic drops in clean. Default `2K` (4K for a hero card).

*(This grammar is the proven Dainami still recipe. Full identity-lock / face-crop rules live in the source project; for a generic subject the role-map above is enough.)*
