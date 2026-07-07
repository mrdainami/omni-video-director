# Recipe — VFX sequence + character insert (+ overlaid text card)

**Effect:** a timed sequence on your footage — an environment FX, then a mascot/character
runs in, then a UI/card element — with clean text added over it at assembly.
**Film:** any clip; the person can stay in frame (preserve them). ≤10s.
**Refs:** the character/mascot/logo as a clean transparent PNG (≤7 refs).

```
PRESERVE (do not change): the real person in frame, their face and exact mouth movements
and timing, and the readable layout.
CHANGE (a timed sequence across the clip): first, <environment FX — e.g. the screen erupts
into crackling blue-white lightning>; then <a character that looks exactly like the reference
image — describe it concretely> runs in from the left and moves through the scene; as it
arrives, <a small BLANK rounded pop-up card> springs up beside it. Cartoon, high-energy.
```

**Assembly (required):**
1. Omni regenerates audio → **re-lay the original audio** over the output (`assemble`).
2. Omni garbles card text → **overlay the real text as a clean graphic** on the blank card
   (a PNG or HyperFrames card), appearing at the beat the card pops (`enable='gte(t,N)'`).

**Proven:** lightning → 2 Claude-Code mascots (from the reference PNG) run in → blank card →
overlaid "WHAT AI DOES / for businesses", real voice re-laid. 168 cr @ 720p/4s, ~280s render.
**Known:** Omni slightly re-times video, so re-laid audio can drift on visible lips (fine for
b-roll under a VO). Sequence order is reliable; exact per-second timing is not.
