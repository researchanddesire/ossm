#!/usr/bin/env bash
set -euo pipefail

CABLE_DIR="hardware/ossm/cables"
OUT_DIR="cable-export"

mkdir -p "$OUT_DIR"

shopt -s nullglob
ymls=("$CABLE_DIR"/*.yml "$CABLE_DIR"/*.yaml)
if [ ${#ymls[@]} -eq 0 ]; then
  echo "No Wireviz YAML in $CABLE_DIR — skipping"
  exit 0
fi

for harness in "${ymls[@]}"; do
  echo "Rendering $harness"
  wireviz "$harness"
  base=$(basename "$harness" .yml)
  base=$(basename "$base" .yaml)
  cp "$CABLE_DIR/$base.png" "$OUT_DIR/" 2>/dev/null || true
  cp "$CABLE_DIR/$base.pdf" "$OUT_DIR/" 2>/dev/null || true
done

ls -la "$OUT_DIR"
