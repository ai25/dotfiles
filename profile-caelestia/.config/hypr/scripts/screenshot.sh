#!/bin/bash

OCR_MODE=0
if [ "$1" = "--ocr" ]; then
  OCR_MODE=1
  shift
fi

TEMP_PNG=$(mktemp)
# we only need the name
rm "$TEMP_PNG"
# Try 'region' option first, then fallback to 'output'
# hyprshot exits with code 1 even on success, so we ignore exit codes
hyprshot -m region -o "$(dirname "$TEMP_PNG")" -f "$(basename "$TEMP_PNG")" -s
# allow the previous overlay to fade out
sleep 0.1
# If region screenshot failed (file doesn't exist), try output mode
if [ ! -f "$TEMP_PNG" ]; then
  hyprshot -m output -m active -o "$(dirname "$TEMP_PNG")" -f "$(basename "$TEMP_PNG")" -s
fi
# Check if screenshot was taken successfully (since hyprshot always returns 1)
if [ ! -f "$TEMP_PNG" ]; then
  notify-send -t 3000 "Screenshot Error" "Failed to capture screenshot"
  exit 1
fi
if [ $OCR_MODE -eq 1 ]; then

  TEMP_DIR=$(mktemp -d)
  TEMP_BASE=$(basename "$TEMP_PNG")
  
  # Check if tesseract is installed
  if ! command -v tesseract >/dev/null 2>&1; then
    notify-send -t 5000 "OCR Error" "Tesseract is not installed. Please install it with 'sudo apt install tesseract-ocr' or equivalent."
    rm "$TEMP_PNG"
    exit 1
  fi
  
   echo "TMP_PNG1: $TEMP_PNG"
   echo "TEXT_FILE1: $TEXT_FILE"
  # rmdir "$TEMP_DIR"
   echo "TEMP_DIR1: $TEMP_DIR"

  tesseract "$TEMP_PNG" "$TEMP_DIR/$TEMP_BASE" -l eng >/dev/null 2>&1
  TEXT_FILE="$TEMP_DIR/$TEMP_BASE.txt"
  
  # Check if OCR was successful
  if [ ! -f "$TEXT_FILE" ]; then
    notify-send -t 3000 "OCR Error" "Failed to extract text from screenshot"
    rm "$TEMP_PNG"
    rmdir "$TEMP_DIR"
    exit 1
  fi
  
  TEXT=$(cat "$TEXT_FILE")
  if command -v wl-copy >/dev/null 2>&1; then
    echo "$TEXT" | wl-copy
  else
    notify-send -t 5000 "Clipboard Warning" "Could not copy to clipboard. Install xclip or wl-copy."
  fi
  
  rm "$TEMP_PNG"
  rm "$TEXT_FILE"
  rmdir "$TEMP_DIR"
  
  notify-send -t 3000 "OCR Complete" "${TEXT:0:100}..."
else
  # Regular screenshot mode with prompt
  WINDOW_ID=$(xprop -root *NET*ACTIVE_WINDOW | cut -d ' ' -f 5)
  
  if [ -n "$WINDOW_ID" ] && [ "$WINDOW_ID" != "0x0" ]; then
    FILENAME=$(zenity --entry --title="Save Screenshot" --text="Enter filename (without extension):" --width=300 --attach=$WINDOW_ID --extra-button="Copy Only" --ok-label="Save")
  else
    # Fallback if window ID is not available
    FILENAME=$(zenity --entry --title="Save Screenshot" --text="Enter filename (without extension):" --width=300 --extra-button="Copy Only" --ok-label="Save")
  fi
  
  EXIT_CODE=$?
  
  # Handle different exit codes
  if [ $EXIT_CODE -eq 1 ]; then
    # Cancel button pressed
    rm "$TEMP_PNG"
    notify-send -t 3000 "Screenshot" "Cancelled by user"
    exit 0
  elif [ $EXIT_CODE -eq 2 ]; then
    # "Copy Only" button pressed
    if command -v wl-copy >/dev/null 2>&1; then
      wl-copy < "$TEMP_PNG"
      notify-send -t 3000 "Screenshot" "Copied to clipboard"
    elif command -v xclip >/dev/null 2>&1; then
      xclip -selection clipboard -t image/png "$TEMP_PNG"
      notify-send -t 3000 "Screenshot" "Copied to clipboard"
    else
      notify-send -t 5000 "Clipboard Warning" "Could not copy to clipboard. Install xclip or wl-copy."
    fi
    rm "$TEMP_PNG"
    exit 0
  fi
  
  # If we reach here, "Save" was pressed (exit code 0)
  
  # If user provides no filename (clicks Save with empty field), use current date/time
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
  
  notify-send -t 3000 "Screenshot Saved" "Saved to $SAVE_PATH"
  
  rm "$TEMP_PNG"
fi
