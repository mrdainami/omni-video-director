# The prompt formula

The single reason this kit beats prompting by hand: a **repeatable prompt grammar** so the models behave. Two grammars — one per model.

---

## A. Gemini Omni — video-to-video (REFERENCES + PRESERVE + CHANGE)

Omni transforms footage you already shot. It will change the *wrong* thing or break lip-sync unless you fence it. Every prompt has up to **three blocks**:

```
REFERENCES (image_urls, ≤7 — optional): any character / object / logo you want Omni to
insert or match, as clean PNGs. In the CHANGE beats, refer to them: "looks EXACTLY like
the reference image". (A good 3D reference → a matching 3D look in-scene.)

PRESERVE (do not change): the person's face + exact mouth movements + timing, their
wardrobe, the room/background, the lighting/colour, the camera framing — plus any object
whose shape must stay. "Keep everything not named below identical to the source."

CHANGE — ONE beat, OR a numbered TIMED SEQUENCE of beats that follow the real motions:
(1) EARLY / while <action>: <beat 1>.
(2) LATER / the moment <trigger, e.g. he tilts the bottle>: <beat 2> [+ simultaneous <beat 2b>].
(3) ...
"Add nothing else."
```

### Rules (all proven on real clips)
1. **You can do MANY beats in one gen** — as long as each beat has its own moment/trigger ("first… then… as he tilts…"). Temporally-separated beats are reliable. Two **simultaneous** changes *can* work (proven: bottle→glass + beard together) but are riskier — test them. Don't pile unrelated changes on the *same instant* carelessly.
2. **Timing = narrative, not timestamps.** Omni has no per-second parameter; it watches your footage and anchors each beat to your real motion (your swipe, your tilt). Direct order with words.
3. **References insert characters/objects.** Put the mascot/product/logo in `image_urls` (≤7) and say "looks exactly like the reference image." Things already in the shot (a bottle → glass, your face → beard) need **no** reference — they're transforms of what's there.
4. **PRESERVE is a fence, not a wish.** Whenever the subject is on screen, name *face + lip-sync + timing* every time, or the mouth desyncs.
5. **Describe events, not adjectives.** "the can catches the key light as he turns it" beats "smooth, cinematic" (renders dead).
6. **No legible text / fine logos in Omni** — it garbles type. Have Omni make a *blank* card/shape, then overlay real text as a clean graphic at assembly (GPT-Image-2 / HyperFrames).
7. **Limits:** source window ≤10s, file ≤30s, aspect 16:9 or 9:16, `1080p` for edit-ready (720p to probe). **Omni regenerates audio → always re-lay your original audio at assembly.**

### Worked example — PROVEN (mascot + bottle + beard, one 7s gen)
```
REFERENCES (image_urls): [ the fluffy 3D mascot PNG ]

PRESERVE (do not change): the man's real face identity and his exact mouth movements and
timing, his black sleeveless top, the wood-panel room and red poster behind him, the
lighting, and the camera framing. Keep his hand and the bottle's shape, size, cap and
motion exactly as in the source. Change ONLY the things below, at the moments described.

CHANGE — a timed sequence that follows his real actions:
(1) EARLY, while he talks: a soft FLUFFY 3D mascot that looks EXACTLY like the reference
image (plush orange-coral, fuzzy fabric, two dark square eyes, stubby legs) crawls up from
behind onto his shoulder and perches. He glances at it. As he raises his hand to swipe, the
mascot is startled and scurries away off his shoulder and out of frame — just BEFORE his
hand reaches it.
(2) LATER, the moment he raises and TILTS the blue bottle, TWO things happen together: the
bottle turns into clear transparent glass (refraction, reflections, bright highlights, water
sloshing), AND he now has a full thick beard — visible directly and through the glass.
Before the tilt: bottle opaque, face clean-shaven. Only these change.

One fluffy 3D mascot only; the bottle photoreal. Add nothing else.
```
→ Submit with `image_urls:[<mascot url>]`, `video_list:[{url,start,ends}]`, aspect 9:16, 720/1080p.

### Blank skeleton to fill
```
REFERENCES (image_urls): [ <ref PNGs, or none> ]
PRESERVE (do not change): <face + mouth timing + wardrobe + room + lighting + camera + any
  object whose shape must stay>. Keep everything not named below identical to the source.
CHANGE:
(1) <when / trigger>: <beat 1, with materials/optics + how it catches the existing light>.
(2) <when / trigger>: <beat 2> [+ <simultaneous beat 2b>].
Add nothing else.
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
- **Style is fully promptable** — same shape, any material ("glossy vinyl toy" vs "soft fluffy plush" vs "claymation"): say it.
- Match the **input video's aspect** so the graphic drops in clean. Default `2K` (4K for a hero card).

*(This grammar is the proven Dainami still recipe. Full identity-lock / face-crop rules live in the source project; for a generic subject the role-map above is enough.)*
