# Quickstart (~5 min)

## 1. Get your keys (just two)
- **kie.ai** (generation — Omni + GPT-Image-2): https://kie.ai → API keys. Pay-as-you-go; add a few dollars of credits.
- **OpenRouter** (analysis — Gemini 3.5 Flash, audio-aware): https://openrouter.ai/keys. Cheap; cents per video.

Set them in your shell (add to `~/.zshrc` to persist):
```bash
export KIE_API_KEY="sk-..."
export OPENROUTER_API_KEY="sk-or-..."
```
*(Optional: for videos longer than ~4 min you can add a native `GEMINI_API_KEY` from https://aistudio.google.com/apikey and use `scripts/analyze_native.sh` instead — handles up to ~1hr.)*

## 2. Install the basics
```bash
# Claude Code: https://claude.com/claude-code
brew install ffmpeg jq        # media + json (macOS; use your package manager elsewhere)
node -v                        # need Node for the HyperFrames assembly step
```

## 3. Drop your video in
Put your clip in `input/` (mp4). **Omni is video-to-video** — it transforms footage you already shot, so give it real footage (you holding/rotating a prop, gesturing, or just talking). See `input/WHAT-TO-FILM.md`.

## 4. Run it
Open this folder in Claude Code and say:
> **"Act as my video director — read the clip in input/ and propose a beat plan."**

Then:
1. It writes `analysis/beat-plan.md` — **you approve/edit the beats**.
2. It crafts the prompt per beat.
3. It shows the cost — **you say go** — it generates on kie.
4. **You watch each clip.** Approved ones get assembled into `output/`.

## First-run cost check
Omni's price isn't fixed — the first time, let it run `scripts/probe-omni.sh <hosted-clip-url>` once (a 720p/4s probe) to learn the real per-clip credits before you batch.

## Costs, honestly
- Analysis (Gemini): cents per video.
- Generation (kie): billed per clip/image on submit — the exact number prints as `creditsConsumed`. You approve every spend.

## Troubleshooting
- `KIE_API_KEY not set` → re-open your terminal after editing `~/.zshrc`, or `export` it again.
- Gemini 400 on a long video → it's still processing; the script waits for `ACTIVE`, but very long files may need `media_resolution: low` (see `analyze-video`).
- A generation drifted (wrong thing changed, lip-sync off) → that's a prompt fix, not a you problem. Tell Claude what went wrong; it re-crafts. See each recipe's "known failure".
