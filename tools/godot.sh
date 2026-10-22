#!/usr/bin/env bash
# Usage : ./tools/godot.sh jeu | tests | editeur | verifier-demarrage | capture <dossier> | export-web
# Binaire Godot 4.7.2 : GODOT_BIN s'il est défini, sinon celui de ffta-remake, sinon « godot » du PATH,
# sinon l'application installée dans /Applications.
set -euo pipefail
RACINE="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
if [[ -z "${GODOT_BIN:-}" ]]; then
  for candidat in "$HOME/Desktop/Projets/ffta-remake/tools/godot/Godot.app/Contents/MacOS/Godot" \
                  "$(command -v godot || true)" "/Applications/Godot.app/Contents/MacOS/Godot"; do
    if [[ -n "$candidat" && -x "$candidat" ]]; then GODOT_BIN="$candidat"; break; fi
  done
fi
GODOT_BIN="${GODOT_BIN:-godot}"
if [[ ! -x "$GODOT_BIN" ]]; then
  echo "Godot introuvable : $GODOT_BIN (définir GODOT_BIN)" >&2
  exit 1
fi

# Les erreurs de script ne changent pas toujours le code de sortie de Godot : on scanne aussi la sortie.
executer_et_scanner() {
  local log statut=0
  log="$(mktemp -t banana_catch.XXXXXX)"
  "$@" 2>&1 | tee "$log" || statut=$?
  if grep -qE 'SCRIPT ERROR|Parse Error|Failed to load script|^ERROR|^WARNING|USER ERROR|USER WARNING' "$log"; then
    echo "godot.sh : erreur ou avertissement détecté dans la sortie" >&2
    statut=1
  fi
  rm -f "$log"
  return $statut
}

# Importe les ressources et met à jour le cache des class_name (sinon un script nouveau reste introuvable).
importer() {
  "$GODOT_BIN" --headless --path "$RACINE" --import >/dev/null 2>&1 || true
}

case "${1:-jeu}" in
  jeu) importer; exec "$GODOT_BIN" --path "$RACINE" ;;
  editeur) exec "$GODOT_BIN" --editor --path "$RACINE" ;;
  tests) importer; executer_et_scanner "$GODOT_BIN" --headless --fixed-fps 60 --path "$RACINE" -s res://tests/run_tests.gd ;;
  verifier-demarrage) importer; executer_et_scanner "$GODOT_BIN" --headless --fixed-fps 60 --path "$RACINE" --quit-after 300 ;;
  capture) importer; DOSSIER_CAPTURES="${2:?dossier de sortie}" executer_et_scanner "$GODOT_BIN" --path "$RACINE" -s res://tools/capture.gd ;;
  export-web) importer; mkdir -p "$RACINE/build/web"; "$GODOT_BIN" --headless --path "$RACINE" --export-release "Web" "$RACINE/build/web/index.html" >/dev/null && echo "Export web : build/web/" ;;
  *) echo "Usage : $0 jeu | tests | editeur | verifier-demarrage | capture <dossier> | export-web" >&2; exit 2 ;;
esac
