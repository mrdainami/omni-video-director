# Quickstart (~5 min)

## 1. Add your two keys → `.env`
```bash
cp .env.example .env      # then open .env and paste your keys
```
- **`KIE_API_KEY`** — generation (Omni + GPT-Image-2). Get it at https://kie.ai → API keys. Pay-as-you-go; add a few dollars.
- **`OPENROUTER_API_KEY`** — analysis (Gemini 3.5 Flash, audio-aware). Get it at https://openrouter.ai/keys. Cents per video.

That's it — every script reads `.env` automatically (it's gitignored, so your keys never get committed). No shell `export` needed.

*(Optional: for videos over ~4 min, add `GEMINI_API_KEY` from https://aistudio.google.com/apikey to `.env` and use `scripts/analyze_native.sh`.)*

### How the tools connect (only ONE is an MCP)
| Tool | What it's for | How it connects |
|---|---|---|
| **kie** | Omni + GPT-Image-2 generation | `KIE_API_KEY` in `.env` (default) — **or** the optional [kie-mcp](https://github.com/mrdainami/kie-mcp) server, see below |
| **OpenRouter** | Gemini reads your video | `OPENROUTER_API_KEY` in `.env`. Not an MCP — just a key. |
| **HyperFrames** | assembles + renders the final | `npx hyperframes` (a CLI). Not an MCP — just needs Node. |
| **ffmpeg** | cut clips + audio | a CLI. `brew install ffmpeg`. |

**Optional — use the kie MCP instead of the key** (cleaner native tools in Claude Code):
```bash
git clone https://github.com/mrdainami/kie-mcp.git ~/mcp/kie-mcp
cd ~/mcp/kie-mcp && npm install && npm run build
claude mcp add --scope user kie --env KIE_API_KEY=YOUR_KEY -- node ~/mcp/kie-mcp/dist/index.js
```
With the MCP added, Claude uses `kie_*` tools directly; without it, the kit's `scripts/kie.sh` does the same over HTTP. Either works — same `KIE_API_KEY`.

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
