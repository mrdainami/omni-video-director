#!/usr/bin/env bash
# new-project.sh — scaffold a fresh video project from the template.
# Usage: new-project.sh <slug>     e.g.  new-project.sh summer-launch
set -euo pipefail
_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
RAW="${1:?usage: new-project.sh <slug>  (short kebab-case name for the video)}"
# normalise → lowercase kebab, strip anything not a-z0-9-
SLUG="$(printf '%s' "$RAW" | tr '[:upper:] ' '[:lower:]-' | tr -cd 'a-z0-9-' | sed -E 's/-+/-/g; s/^-|-$//g')"
[ -n "$SLUG" ] || { echo "error: name '$RAW' produced an empty slug"; exit 1; }
DEST="$_ROOT/projects/$SLUG"
[ -e "$DEST" ] && { echo "error: projects/$SLUG already exists — pick another name"; exit 1; }
cp -R "$_ROOT/projects/_TEMPLATE" "$DEST"
# guarantee the standard subfolders exist even if the repo shipped without empty dirs
mkdir -p "$DEST"/input "$DEST"/analysis "$DEST"/assets/refs "$DEST"/beats "$DEST"/output
echo "created: projects/$SLUG"
echo "  input/       ← drop your source video here"
echo "  analysis/    ← beat-plan.md + words.json land here"
echo "  beats/<seg>/ ← per-beat cut + Omni generation (auto)"
echo "  assets/refs/ ← reference stills + graphic cards (auto)"
echo "  output/      ← the finished cut"
printf '%s' "$SLUG"
