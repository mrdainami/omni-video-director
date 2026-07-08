# 🎬 AI Video Director

Drop a video in. Claude finds where a **b-roll or graphic** belongs, writes the exact prompt, generates it (Google **Gemini Omni** for VFX on your footage, **GPT-Image-2** for graphics — both via [kie.ai](https://kie.ai)), and drops it back into your cut. A b-roll editor that works while you review.

You bring one thing every scene actually needs: **taste.** You pick the beats; the Director nails the prompt that makes the model behave.

```
you: "start a new project" → drop your clip in projects/<name>/input/ → "act as my video director"
claude: reads it → proposes a beat plan → you approve → generates → you watch → drops it in → output/
```

## What it does
- **Understands your video** — Gemini 3.5 Flash watches the footage + hears the audio, and marks the beats worth a b-roll/graphic (with timestamps).
- **Crafts the prompt** — the part everyone gets wrong. A proven two-part constraint prompt for Omni; a multi-reference brief for GPT-Image-2.
- **Generates on kie** — one API key for both models.
- **Assembles it back** — cuts the segment, drops the asset in, renders the finished cut.

## Get started
See **[QUICKSTART.md](QUICKSTART.md)** — get a kie key, drop a clip, run it. ~5 minutes.

## What you need
- [Claude Code](https://claude.com/claude-code)
- A **kie.ai** API key (pay-as-you-go; Omni + GPT-Image-2 both live here)
- An **OpenRouter** API key (the analysis step — Gemini 3.5 Flash, audio-aware; cents per video)
- `ffmpeg` + `node` (for the assembly step)

> Honest heads-up: **Omni is video-to-video** — it transforms footage you already shot. You need a real clip to point it at. And generation costs kie credits (the exact price prints when you submit).

---
Built by [Dainami AI](https://dainami.ai). Want the whole system that runs a business on agents? → the [AI OS Blueprint](https://dainami.ai/resources/ai-os-blueprint).
