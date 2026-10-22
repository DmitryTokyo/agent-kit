#!/usr/bin/env bash
# Render the kit's skills and packs at one commit for one project.
# Usage: render.sh <commit> <prefix> <out-dir>
# Output: <out-dir>/skills/<prefix>-<name>/... with {{p}} replaced, <out-dir>/packs/<name>/... as is.
# bootstrap and sync run from the kit and are not rendered.
set -euo pipefail

commit=$1
prefix=$2
out=$3
kit=$(cd "$(dirname "$0")/.." && pwd)

[[ $prefix =~ ^[a-z][a-z0-9]*$ ]] || { echo "prefix must be lowercase letters and digits: $prefix" >&2; exit 1; }
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
find "$out/skills" -type f -name '*.md' -exec perl -pi -e "s/\{\{p\}\}/$prefix/g" {} +
cp -R "$tmp/packs" "$out/packs"
