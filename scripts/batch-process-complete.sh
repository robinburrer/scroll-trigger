#!/bin/bash

# Get current script directory
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Input/output directories
INPUT_DIR="/Users/robinburrer/Desktop/frames-input"
OUTPUT_PNG_DIR="/Users/robinburrer/Desktop/frames-output"
OUTPUT_WEBP_DIR="/Users/robinburrer/Desktop/webp-output"
SCRIPT="$SCRIPT_DIR/remove-bg.scpt"

# Create output directories
mkdir -p "$OUTPUT_PNG_DIR"
mkdir -p "$OUTPUT_WEBP_DIR"

# Remove background from each JPG using AppleScript
shopt -s nullglob
jpg_files=("$INPUT_DIR"/frame-*.jpg)

if [ ${#jpg_files[@]} -eq 0 ]; then
  echo "❌ No matching .jpg files found in $INPUT_DIR"
  exit 1
fi

echo "🔄 Removing backgrounds and exporting to PNG..."
for file in "${jpg_files[@]}"; do
  filename=$(basename "$file" .jpg)
  output_png="$OUTPUT_PNG_DIR/${filename}.png"
  echo "🖼️  $file → $output_png"
  osascript "$SCRIPT" "$file" "$output_png"
done

# Convert PNGs to WebP
echo "🎯 Converting PNGs to WebP..."
for f in "$OUTPUT_PNG_DIR"/*.png; do
  fname=$(basename "$f" .png)
  output_webp="$OUTPUT_WEBP_DIR/${fname}.webp"
  echo "📦 $f → $output_webp"
  cwebp -q 1 "$f" -o "$output_webp"
done

echo "✅ All done."