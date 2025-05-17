#!/bin/bash

# Get current script directory
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Input/output directories
INPUT_DIR="/Users/robinburrer/Desktop/frames-input"
OUTPUT_PNG_DIR="/Users/robinburrer/Desktop/frames-output"
OUTPUT_FLATTENED_DIR="/Users/robinburrer/Desktop/frames-output-flattened"
OUTPUT_WEBP_DIR="/Users/robinburrer/Desktop/webp-output"
SCRIPT="$SCRIPT_DIR/remove-bg.scpt"

# Create output directories
mkdir -p "$OUTPUT_PNG_DIR"
mkdir -p "$OUTPUT_FLATTENED_DIR"
mkdir -p "$OUTPUT_WEBP_DIR"

# Enable nullglob so *.png doesn't return literal string if no match
shopt -s nullglob
png_files=("$INPUT_DIR"/*.png)

if [ ${#png_files[@]} -eq 0 ]; then
  echo "❌ No matching .png files found in $INPUT_DIR"
  exit 1
fi

echo "🔄 Removing backgrounds and exporting to PNG..."
for file in "${png_files[@]}"; do
  filename=$(basename "$file" .png)
  output_png="$OUTPUT_PNG_DIR/${filename}.png"
  echo "🖼️  $file → $output_png"
  osascript "$SCRIPT" "$file" "$output_png"
done

echo "🎨 Flattening PNGs to remove transparency (white background)..."
for f in "$OUTPUT_PNG_DIR"/*.png; do
  fname=$(basename "$f")
  flattened="$OUTPUT_FLATTENED_DIR/$fname"
  echo "🔧 Flattening $f → $flattened"
  convert "$f" -background white -alpha remove -alpha off "$flattened"
done

echo "🎯 Converting flattened PNGs to WebP with strict sequential filenames..."
counter=1
for f in "$OUTPUT_FLATTENED_DIR"/*.png; do
  num=$(printf "%03d" $counter)
  output_webp="$OUTPUT_WEBP_DIR/${num}.webp"
  echo "📦 $f → $output_webp"
  cwebp -q 1 "$f" -o "$output_webp"
  ((counter++))
done

echo "✅ All done."