# Recipe — material morph

**Effect:** an object changes material (plastic → chrome / glass / wood) with correct reflections.
**Film:** rotate the object on a surface with a visible reflection (table), steady light. ≤10s.

```
PRESERVE (do not change): the object's shape and position, the hand, the background,
the table surface, and the existing lighting and camera. Keep everything not named below
identical to the source.
CHANGE (one effect): the [mug]'s material becomes [polished chrome]; it shows sharp
environment reflections and specular highlights, and its reflection maps correctly onto
the [glass table] beneath it as it turns.
```
**Known failure:** naming two materials at once = drift. One material per generation. Reflections on a matte surface won't map — needs a reflective surface in-shot.
