#!/bin/bash

STATE_FILE="/tmp/scroll_screenshot_state"
TEMP_DIR="/tmp/scroll_screenshots"

case "$1" in
toggle)
  # If no active session, start one
  if [ ! -f "$STATE_FILE" ]; then
    rm -rf "$TEMP_DIR"
    mkdir -p "$TEMP_DIR"
    echo "0" >"$STATE_FILE"

    REGION=$(slurp)
    if [ -z "$REGION" ]; then
      notify-send "Cancelled" "No region selected"
      rm "$STATE_FILE"
      exit 0
    fi

    echo "$REGION" >"$STATE_FILE.region"
    notify-send "Scroll Screenshot Started" "Press Super+Shift+S to capture frames, Super+Shift+F to finish"
    exit 0
  fi

  # Session exists—capture frame
  COUNTER=$(cat "$STATE_FILE")
  REGION=$(cat "$STATE_FILE.region")

  TEMP_FILE="$TEMP_DIR/shot_$(printf '%03d' $COUNTER).png"
  grim -g "$REGION" "$TEMP_FILE"

  COUNTER=$((COUNTER + 1))
  echo "$COUNTER" >"$STATE_FILE"

  notify-send -t 800 "Frame $COUNTER captured" "Scroll and press Super+Shift+S again"
  ;;

finish)
  if [ ! -f "$STATE_FILE" ]; then
    notify-send "Error" "No active scroll screenshot session"
    exit 1
  fi

  COUNTER=$(cat "$STATE_FILE")

  if [ "$COUNTER" -eq 0 ]; then
    notify-send "Cancelled" "No frames captured"
    rm -rf "$TEMP_DIR" "$STATE_FILE" "$STATE_FILE.region"
    exit 0
  fi

  OUTPUT="$HOME/Pictures/scroll_$(date +%Y%m%d_%H%M%S).png"
  convert "$TEMP_DIR"/shot_*.png -append "$OUTPUT"

  notify-send "Complete" "Stitched $COUNTER frames → $OUTPUT"

  rm -rf "$TEMP_DIR" "$STATE_FILE" "$STATE_FILE.region"
  ;;

*)
  echo "Usage: $0 {toggle|finish}"
  exit 1
  ;;
esac
