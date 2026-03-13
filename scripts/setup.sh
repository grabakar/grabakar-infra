#!/bin/bash
# GrabaKar — Setup: clona todos los repos del proyecto
set -e

REPO_ORG="grabakar"
REPOS_DIR="$(dirname "$0")/../repos"

mkdir -p "$REPOS_DIR"

clone_or_pull() {
  local name="$1"
  local dir="$REPOS_DIR/$name"
  if [ -d "$dir/.git" ]; then
    echo "⬆️  Actualizando $name..."
    (cd "$dir" && git pull --ff-only 2>/dev/null || echo "⚠️  Pull falló — puede haber cambios locales")
  else
    echo "📥 Clonando $name..."
    git clone "git@github.com:$REPO_ORG/$name.git" "$dir"
  fi
}

clone_or_pull "grabakar-backend"
clone_or_pull "grabakar-frontend"
clone_or_pull "grabakar-docs"

echo ""
echo "✅ Todos los repos listos en $REPOS_DIR/"
echo ""
echo "Siguiente paso: copiar .env.example a .env y ejecutar:"
echo "  docker compose up -d"
