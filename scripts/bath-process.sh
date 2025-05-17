#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"


INPUT_DIR="/Users/robinburrer/Desktop/frames-input"
OUTPUT_DIR="/Users/robinburrer/Desktop/frames-output"
SCRIPT="$SCRIPT_DIR/remove-bg.scpt"

mkdir -p "$OUTPUT_DIR"

for file in "$INPUT_DIR"/frame-*.jpg; do
    filename=$(basename "$file" .jpg)
    output="$OUTPUT_DIR/${filename}.png"
    echo "Processing $file -> $output"
    osascript "$SCRIPT" "$file" "$output"
done


# #!/bin/bash
# # Get the directory where this script is located
# SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# INPUT_DIR="$SCRIPT_DIR/frames-input"
# OUTPUT_DIR="$SCRIPT_DIR/frames-output"
# SCRIPT="$SCRIPT_DIR/remove-bg.scpt"

# mkdir -p "$OUTPUT_DIR"

# for file in "$INPUT_DIR"/frame-*.jpg; do
#     filename=$(basename "$file" .jpg)
#     output="$OUTPUT_DIR/${filename}.png"
#     echo "Processing $file -> $output"
#     osascript "$SCRIPT" "$file" "$output"
# done