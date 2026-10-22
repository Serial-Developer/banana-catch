#!/usr/bin/env bash
# Exporte la version web et la publie sur la branche gh-pages (GitHub Pages).
# Usage : ./tools/publier_web.sh
set -euo pipefail
RACINE="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
"$RACINE/tools/godot.sh" export-web
DEPOT="$(git -C "$RACINE" remote get-url origin)"
TEMP="$(mktemp -d -t banana_catch_pages.XXXXXX)"
cp -R "$RACINE/build/web/." "$TEMP/"
touch "$TEMP/.nojekyll"
git -C "$TEMP" init -q -b gh-pages
git -C "$TEMP" add -A
git -C "$TEMP" commit -qm "Version web ($(git -C "$RACINE" rev-parse --short HEAD))"
git -C "$TEMP" push -qf "$DEPOT" gh-pages
rm -rf "${TEMP:?}"
echo "Publié sur la branche gh-pages."
