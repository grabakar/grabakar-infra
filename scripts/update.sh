#!/bin/bash
# GrabaKar — Update: pull latest de todos los repos
set -e

REPOS_DIR="$(dirname "$0")/../repos"

if [ ! -d "$REPOS_DIR" ]; then
  echo "❌ No se encontró el directorio repos/. Ejecutar setup.sh primero."
  exit 1
fi

for repo in "$REPOS_DIR"/*/; do
  name=$(basename "$repo")
  if [ -d "$repo/.git" ]; then
    echo "⬆️  $name..."
    (cd "$repo" && git pull --ff-only 2>/dev/null || echo "⚠️  $name: pull falló, revisar manualmente")
  fi
done

echo ""
echo "✅ Todos los repos actualizados."
