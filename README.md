# 🎬 Omni Video Director

**Drop in a video and AI adds the graphics and effects for you** — turn a bottle transparent, make a little mascot climb on your shoulder, drop in animated stat cards, give yourself a beard. You pick *where*; the AI does the rest. You bring the video, it brings the effects.

## What you'll need
Three sign-ups + a couple of free tools. All spelled out below — it's fine if these are new to you.
- **Claude Code** — the app you'll "talk" to (it runs everything).
- **A [kie.ai](https://kie.ai?ref=41abfa41934c4f15a97d88d2d4f8162a) account** — lets Claude use **Google Omni** to add graphic effects to your work. *Pay-as-you-go: load a few dollars; each effect costs a little.*
- **An [OpenRouter](https://openrouter.ai/keys) account** — lets you access models like **Google Gemini 3.5 Flash** to analyse your videos. *Costs pennies.*
- **ffmpeg + jq** — free background tools that stitch and read your files. Install once. (Node is optional — only if you later switch on the kie MCP; see QUICKSTART.)

## Part 1 — One-time setup (~10 min, only done once)

**1. Install Claude Code** → https://claude.com/claude-code (follow their installer).

**2. Install the background tools.** Open the **Terminal** app (Mac: press ⌘+Space, type "Terminal", Enter), paste this, press Enter:
```
brew install ffmpeg jq
```
*(No "brew"? Install it first from https://brew.sh. On Windows: get ffmpeg from ffmpeg.org and jq from jqlang.github.io/jq.)*

**3. Get the kit.** On this GitHub page click the green **"Use this template" → Create a new repository** (or just **Code → Download ZIP** and unzip it).

**4. Get your 2 keys.** A "key" is a password that lets the kit use a service (and bills you for what you use).
- **kie:** [kie.ai](https://kie.ai?ref=41abfa41934c4f15a97d88d2d4f8162a) → sign up → **Dashboard → API Keys** → copy. Then add a few dollars of credit.
- **OpenRouter:** https://openrouter.ai/keys → sign up → **Create Key** → copy.

**5. Paste your keys in.** In the kit folder, copy the file `.env.example` and name the copy `.env`. Open it and paste your keys after the `=`:
```
KIE_API_KEY=your-kie-key-here
OPENROUTER_API_KEY=your-openrouter-key-here
```
Save it. **Setup done — you never do this part again.**
*(Shortcut: open the folder in Claude Code and say "help me set up my .env" — it'll walk you through it.)*

## Part 2 — Make a video (every time)

**6. Film a short clip** on your phone — you talking, holding a prop, gesturing. It transforms *real* footage, so give it something real. (See `projects/_TEMPLATE/input/WHAT-TO-FILM.md` for ideas.)

**7. Start a project.** Open the folder in Claude Code and say:
> **"Start a new project called my-first-video"**

It makes a folder and tells you where to drop your clip. Put your video there.

**8. Let it direct.** Say:
> **"Act as my video director."**

Then it's a simple back-and-forth:
1. It watches your video and suggests where effects go → **you approve or edit the list.**
2. It writes the exact instructions for each effect.
3. It shows the cost → **you say "go"** → it makes the effect.
4. **You watch each one** → keep what you like.
5. It stitches your finished video into the `output/` folder.

## Good to know
- **It never spends your money without asking** — you approve every effect first.
- **Costs are small** — usually a fraction of a dollar per effect, shown before each one.
- **You're the director** — if something's off, just say so and it redoes it.

---

*Advanced / optional (the cleaner "kie MCP" setup, long-video analysis, troubleshooting): see [QUICKSTART.md](QUICKSTART.md).*

Built by [Dainami AI](https://dainami.ai). Want the whole system that runs a business on AI agents? → the [AI OS Blueprint](https://dainami.ai/resources/ai-os-blueprint).
