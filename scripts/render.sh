#!/usr/bin/env bash
# Render the kit's skills and packs at one commit for one project.
# Usage: render.sh <commit> <prefix> <work> <out-dir>
# <work> is the project's working folder for task files, relative to the repository root (e.g. .ai).
# Output: <out-dir>/skills/<prefix>-<name>/... with {{p}} and {{work}} replaced, <out-dir>/packs/<name>/... as is.
# bootstrap and sync run from the kit and are not rendered.
set -euo pipefail

commit=$1
prefix=$2
work=$3
out=$4
kit=$(cd "$(dirname "$0")/.." && pwd)

[[ $prefix =~ ^[a-z][a-z0-9]*$ ]] || { echo "prefix must be lowercase letters and digits: $prefix" >&2; exit 1; }
[[ $work =~ ^[A-Za-z0-9._-]+(/[A-Za-z0-9._-]+)*$ && ! $work =~ (^|/)\.\.?(/|$) ]] ||
  { echo "work must be a relative path inside the repository, e.g. .ai: $work" >&2; exit 1; }
mkdir -p "$out"
[ -z "$(ls -A "$out")" ] || { echo "out-dir is not empty: $out" >&2; exit 1; }

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
git -C "$kit" archive "$commit" skills packs | tar -x -C "$tmp"

mkdir -p "$out/skills"
for dir in "$tmp"/skills/*/; do
  name=$(basename "$dir")
  case $name in bootstrap|sync) continue ;; esac
  cp -R "$dir" "$out/skills/$prefix-$name"
done
PREFIX=$prefix WORK=$work find "$out/skills" -type f -name '*.md' \
  -exec perl -pi -e 's/\{\{p\}\}/$ENV{PREFIX}/g; s/\{\{work\}\}/$ENV{WORK}/g' {} +
cp -R "$tmp/packs" "$out/packs"
