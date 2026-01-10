#!/bin/bash

# Configuration - adjust these to your preference
FLOAT_WIDTH="96%"  # Percentage of screen width
FLOAT_HEIGHT="92%" # Percentage of screen height

# Alternative: Use fixed pixel sizes
# FLOAT_WIDTH="1200"
# FLOAT_HEIGHT="800"

# Get current window info
WINDOW_INFO=$(hyprctl activewindow -j)
FOCUSED_WINDOW=$(echo "$WINDOW_INFO" | jq -r '.address')
IS_FLOATING=$(echo "$WINDOW_INFO" | jq -r '.floating')
WINDOW_CLASS=$(echo "$WINDOW_INFO" | jq -r '.class')

echo "DEBUG: Window: $FOCUSED_WINDOW"
echo "DEBUG: Class: $WINDOW_CLASS"
echo "DEBUG: Currently floating: $IS_FLOATING"

if [[ "$IS_FLOATING" == "true" ]]; then
  # Window is floating, toggle it back to tiled
  echo "Window is floating, returning to tiled mode"
  hyprctl dispatch togglefloating
else
  # Window is tiled, make it float with our desired size
  echo "Window is tiled, switching to floating mode"
  echo "Target size: ${FLOAT_WIDTH} x ${FLOAT_HEIGHT}"

  # Use batch mode to execute all commands together for smoother transition
  hyprctl --batch "dispatch togglefloating ; dispatch resizeactive exact $FLOAT_WIDTH $FLOAT_HEIGHT ; dispatch centerwindow"
fi

# Verify the result
sleep 0.1
NEW_INFO=$(hyprctl activewindow -j)
NEW_FLOATING=$(echo "$NEW_INFO" | jq -r '.floating')
NEW_SIZE=$(echo "$NEW_INFO" | jq -r '"\(.size[0])x\(.size[1])"')
echo "DEBUG: New floating state: $NEW_FLOATING"
echo "DEBUG: New size: $NEW_SIZE"
