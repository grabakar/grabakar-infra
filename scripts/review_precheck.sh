#!/bin/bash
# review_precheck.sh — run from repo root (backend has api/, frontend has src/)
set -e
ROOT="${1:-.}"
cd "$ROOT"

echo "=== Brand Name Check ==="
(grep -rn '"GrabaKar"' api/ src/ --include="*.py" --include="*.ts" --include="*.tsx" 2>/dev/null || true) | grep -v test | grep -v fixture | grep -v DEFAULTS || true

if [ -d api ]; then
  echo "=== Raw SQL Check ==="
  grep -rn '\.raw(' api/ --include="*.py" 2>/dev/null || true
  grep -rn '\.extra(' api/ --include="*.py" 2>/dev/null || true
  echo "=== Secrets Check ==="
  (grep -rn 'password.*=' api/ --include="*.py" 2>/dev/null || true) | grep -v 'os.getenv\|settings\.\|test\|factory\|mock\|fixture' || true
  echo "=== Tenant Mixin Check ==="
  for f in $(grep -rl 'class.*ViewSet' api/views/ --include="*.py" 2>/dev/null || true); do
    grep -q 'TenantQuerySetMixin' "$f" || echo "MISSING: $f"
  done
fi

echo "=== Pre-check done ==="
