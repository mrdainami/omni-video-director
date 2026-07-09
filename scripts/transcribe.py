#!/usr/bin/env python3
"""transcribe.py — frame-accurate WORD timestamps via Whisper large-v3 on OpenRouter.

Why this exists: Gemini (analyze.py) is great for the transcript TEXT and rough beat-marking,
but its per-second TIMESTAMPS drift. For cutting segments on exact phrase boundaries you need
real ASR word timings. OpenRouter serves whisper-large-v3 over the OpenAI-compatible
/audio/transcriptions endpoint — same OPENROUTER_API_KEY as analyze.py, no local install.

Usage: python3 scripts/transcribe.py input/<clip>.mp4 > analysis/words.json
Note: Whisper nails TIMING but may mis-hear proper nouns ("Omni"->"only", "Claude"->"cloud").
Timing is what we cut on; fix the few names by hand using analyze.py's text.
"""
import json, os, subprocess, sys, tempfile, pathlib, urllib.request, uuid

def _load_env():
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
key = os.environ.get("OPENROUTER_API_KEY") or sys.exit("OPENROUTER_API_KEY not set")

with tempfile.TemporaryDirectory() as td:
    mp3 = f"{td}/a.mp3"
    subprocess.run(["ffmpeg", "-y", "-loglevel", "error", "-i", video,
                    "-vn", "-ac", "1", "-ar", "16000", "-b:a", "96k", mp3], check=True)
    audio = open(mp3, "rb").read()

# multipart/form-data by hand (no deps)
boundary = "----avd" + uuid.uuid4().hex
def part(name, value):
    return (f'--{boundary}\r\nContent-Disposition: form-data; name="{name}"\r\n\r\n{value}\r\n').encode()
body  = part("model", "openai/whisper-large-v3")
body += part("response_format", "verbose_json")
body += part("timestamp_granularities[]", "word")
body += (f'--{boundary}\r\nContent-Disposition: form-data; name="file"; filename="a.mp3"\r\n'
         f'Content-Type: audio/mpeg\r\n\r\n').encode() + audio + b"\r\n"
body += f"--{boundary}--\r\n".encode()

req = urllib.request.Request("https://openrouter.ai/api/v1/audio/transcriptions", data=body,
        headers={"Authorization": f"Bearer {key}",
                 "Content-Type": f"multipart/form-data; boundary={boundary}"})
resp = json.load(urllib.request.urlopen(req, timeout=240))
print(json.dumps({"text": resp.get("text",""),
                  "duration": resp.get("duration"),
                  "words": resp.get("words", [])}, indent=2))
