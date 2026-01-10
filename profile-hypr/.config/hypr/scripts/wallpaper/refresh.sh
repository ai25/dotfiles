#!/bin/bash
# Used by automatic wallpaper change
WALLUST_SWWW=$HOME/.config/hypr/scripts/wallpaper/wallust-swww.sh

echo "about to execute wallust"

# Define file_exists function
file_exists() {
    if [ -e "$1" ]; then
        return 0  # File exists
    else
        return 1  # File does not exist
    fi
}

# Kill already running processes
_ps=(rofi)
for _prs in "${_ps[@]}"; do  # Fixed: consistent variable names
    if pidof "${_prs}" >/dev/null; then
        pkill "${_prs}"
    fi
done

# Wallust refresh
$WALLUST_SWWW
# reload swaync
timeout 5 swaync-client --reload-config

exit 0
