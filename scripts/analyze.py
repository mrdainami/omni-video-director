#!/usr/bin/env python3
"""analyze.py — watch a video (frames + AUDIO) via Gemini 3.5 Flash on OpenRouter, return beats.

One key: OPENROUTER_API_KEY (audio-aware — confirmed transcribes speech). The video is
downscaled + base64'd into the request, so no native Gemini key and no file upload needed.

Usage: OPENROUTER_API_KEY=... python3 analyze.py input/<clip>.mp4 > analysis/beats.json
For very long videos (>~4 min) the base64 payload gets large — downscale harder or chunk
(see analyze-video/SKILL.md). For a no-audio ultra-light fallback use analyze_frames.py.
"""
import base64, json, os, subprocess, sys, tempfile, urllib.request, pathlib

def _load_env():  # fill os.environ from the project-root .env (no dependency)
    for d in (pathlib.Path.cwd(), pathlib.Path(__file__).resolve().parent.parent):
        f = d / ".env"
        if f.exists():
            for ln in f.read_text().splitlines():
                ln = ln.strip()
                if ln and not ln.startswith("#") and "=" in ln:
                    k, v = ln.split("=", 1)
                    os.environ.setdefault(k.strip(), v.strip().strip('"').strip("'"))
            return
_load_env()

video = sys.argv[1]
key = os.environ.get("OPENROUTER_API_KEY") or sys.exit("OPENROUTER_API_KEY not set — copy .env.example to .env and fill it in")

with tempfile.TemporaryDirectory() as td:
    small = f"{td}/small.mp4"
    # downscale to keep the base64 payload sane; keep audio (that's the point)
    subprocess.run(["ffmpeg", "-y", "-loglevel", "error", "-i", video,
                    "-vf", "scale=640:-2", "-r", "10", "-c:v", "libx264", "-crf", "32",
                    "-c:a", "aac", "-b:a", "64k", small], check=True)
    b = base64.b64encode(open(small, "rb").read()).decode()

prompt = (
 "Watch this video — its frames AND its audio (what the person says). Identify the moments "
 "where adding a B-ROLL clip or an on-screen GRAPHIC would most improve it.\n"
 "- Anchor beats to what is SAID: a named concept, a stat/number, a list, a claim wanting proof, "
 "a place/product/tool mentioned, or a flat talking-head stretch needing energy.\n"
 "- Use MM:SS timestamps. end after start. Each beat 1.5-5s.\n"
 "- beat_type: 'vfx' for real-world/product/screen b-roll; 'graphic' for text/stats/diagrams.\n"
 "- reason = the spoken line/context; suggestion = the concrete thing to add.\n"
 'Return ONLY a JSON object {"beats":[{start,end,beat_type,reason,suggestion}]}, 5-15 beats.')

body = json.dumps({"model": "google/gemini-3.5-flash",
    "messages": [{"role": "user", "content": [
        {"type": "text", "text": prompt},
        {"type": "video_url", "video_url": {"url": f"data:video/mp4;base64,{b}"}}]}],
    "response_format": {"type": "json_object"}}).encode()
req = urllib.request.Request("https://openrouter.ai/api/v1/chat/completions", data=body,
        headers={"Authorization": f"Bearer {key}", "Content-Type": "application/json"})
resp = json.load(urllib.request.urlopen(req, timeout=240))
print(resp["choices"][0]["message"]["content"])
