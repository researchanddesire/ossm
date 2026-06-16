#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
CABLE_DIR="$REPO_ROOT/hardware/cables"
OUT_DIR="$REPO_ROOT/cable-export"

mkdir -p "$OUT_DIR"

shopt -s nullglob
ymls=("$CABLE_DIR"/*.yml "$CABLE_DIR"/*.yaml)
if [ ${#ymls[@]} -eq 0 ]; then
  echo "No Wireviz YAML in $CABLE_DIR — skipping"
  exit 0
fi

for harness in "${ymls[@]}"; do
  echo "Rendering $harness"
  base=$(basename "$harness")
  (
    cd "$CABLE_DIR"
    wireviz "$base"
  )
  base="${base%.*}"
  if [ -f "$CABLE_DIR/$base.gv" ] && command -v dot >/dev/null 2>&1; then
    (
      cd "$CABLE_DIR"
      dot -Tpdf "$base.gv" -o "$base.pdf"
    ) || true
  fi
  cp "$CABLE_DIR/$base.bom.tsv" "$OUT_DIR/" 2>/dev/null || true
  cp "$CABLE_DIR/$base.png" "$OUT_DIR/" 2>/dev/null || true
  cp "$CABLE_DIR/$base.pdf" "$OUT_DIR/" 2>/dev/null || true
done

ls -la "$OUT_DIR"
