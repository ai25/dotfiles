#!/bin/bash

# Take screenshot with grimshot
TEMP_PNG=$(mktemp --suffix=.png)
grimshot savecopy anything "$TEMP_PNG"

# Check if screenshot was taken successfully
if [ ! -f "$TEMP_PNG" ]; then
  notify-send -t 3000 "Screenshot Error" "Failed to capture screenshot"
  exit 1
fi

WINDOW_ID=$(xprop -root _NET_ACTIVE_WINDOW | cut -d ' ' -f 5)
# Use zenity to prompt for filename
FILENAME=$(zenity --entry --title="Save Screenshot" --text="Enter filename (without extension):" --width=300 --attach=$WINDOW_ID)

# If user cancels (presses Esc or clicks Cancel), exit
if [ $? -ne 0 ]; then
  rm "$TEMP_PNG"
  notify-send -t 3000 "Screenshot" "Cancelled by user"
  exit 0
fi

# If user provides no filename (clicks OK with empty field), use current date/time
if [ -z "$FILENAME" ]; then
  FILENAME=$(date +"%Y-%m-%d_%H-%M-%S")
  notify-send -t 3000 "Screenshot" "No filename provided. Using date: $FILENAME"
fi

# Create Pictures directory if it doesn't exist
SAVE_DIR="$HOME/Pictures"
mkdir -p "$SAVE_DIR"

# Save as JPG
SAVE_PATH="$SAVE_DIR/$FILENAME.jpg"
convert "$TEMP_PNG" "$SAVE_PATH"

# Clean up temp file
rm "$TEMP_PNG"

# Notify user (with 3 second timeout)
notify-send -t 3000 "Screenshot Saved" "Saved to $SAVE_PATH"
