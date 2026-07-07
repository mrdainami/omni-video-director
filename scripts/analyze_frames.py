#!/usr/bin/env python3
"""analyze_frames.py — FALLBACK analyzer for users with an OpenRouter key (no native Gemini key).

The primary path is scripts/analyze.sh (native Gemini File API — sees full video + audio).
This fallback samples frames with ffmpeg and sends them to gemini-3.5-flash via OpenRouter,
which accepts images. It loses AUDIO (frames only) — good enough to prove/scan a video, but
the native path is better when you have a GEMINI_API_KEY.

Usage: OPENROUTER_API_KEY=... python3 analyze_frames.py <video.mp4> [every_sec]
Prints the beats JSON array [{start_sec,end_sec,beat_type,reason,suggestion}].
"""
import base64, json, os, subprocess, sys, tempfile, urllib.request

video = sys.argv[1]
every = float(sys.argv[2]) if len(sys.argv) > 2 else 2.0
key = os.environ.get("OPENROUTER_API_KEY") or sys.exit("set OPENROUTER_API_KEY")

with tempfile.TemporaryDirectory() as td:
    subprocess.run(["ffmpeg", "-y", "-loglevel", "error", "-i", video,
                    "-vf", f"fps=1/{every},scale=512:-1", f"{td}/f_%03d.jpg"], check=True)
    frames = sorted(f for f in os.listdir(td) if f.endswith(".jpg"))
    parts = [{"type": "text", "text":
        "These are frames sampled every %g seconds from a video (frame N is at about "
        "t=(N-1)*%g seconds). Watch the sequence and mark the moments that most want a "
        "B-ROLL clip or an on-screen GRAPHIC.\n"
        "- beat_type: 'vfx' for real-world/product/screen b-roll; 'graphic' for text/stats/diagrams.\n"
        "- start_sec/end_sec: integer seconds; end>start; each beat 1.5-5s.\n"
        "- reason = why; suggestion = the concrete thing to add.\n"
        "Return ONLY a JSON array of {start_sec,end_sec,beat_type,reason,suggestion}, 4-12 beats."
        % (every, every)}]
    for i, f in enumerate(frames):
        b = base64.b64encode(open(f"{td}/{f}", "rb").read()).decode()
        parts.append({"type": "text", "text": f"[frame {i+1} ~ t={int(i*every)}s]"})
        parts.append({"type": "image_url", "image_url": {"url": f"data:image/jpeg;base64,{b}"}})

body = json.dumps({"model": "google/gemini-3.5-flash",
                   "messages": [{"role": "user", "content": parts}],
                   "response_format": {"type": "json_object"}}).encode()
req = urllib.request.Request("https://openrouter.ai/api/v1/chat/completions", data=body,
        headers={"Authorization": f"Bearer {key}", "Content-Type": "application/json"})
resp = json.load(urllib.request.urlopen(req, timeout=180))
out = resp["choices"][0]["message"]["content"]
print(out)
