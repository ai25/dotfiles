#!/bin/bash
# Wallust Colors for current wallpaper
# Define the path to the swww cache directory
cache_dir="$HOME/.cache/swww/"

# Get current focused monitor
current_monitor=$(hyprctl monitors | awk '/^Monitor/{name=$2} /focused: yes/{print name}')
echo $current_monitor

# Construct the full path to the cache file
cache_file="$cache_dir$current_monitor"
echo $cache_file

# Check if the cache file exists for the current monitor output
if [ -f "$cache_file" ]; then
    # Get the wallpaper path from the cache file
    wallpaper_path=$(grep -v 'Lanczos3' "$cache_file" | head -n 1)
    echo $wallpaper_path
    
    # symlink the wallpaper to the location Rofi can access
    if ln -sf "$wallpaper_path" "$HOME/.config/rofi/.current_wallpaper"; then
        # copy the wallpaper for wallpaper effects
        cp -r "$wallpaper_path" "$HOME/.config/hypr/wallpaper_effects/.wallpaper_effects_current"
        
        # execute wallust with timeout
        echo 'about to execute wallust'
        if timeout 15 wallust run "$wallpaper_path" -s; then
            echo 'wallust executed successfully'
        else
            exit_code=$?
            if [ $exit_code -eq 124 ]; then
                echo 'wallust timed out after 15 seconds'
            else
                echo "wallust failed with exit code $exit_code"
            fi
        fi
    else
        echo "Failed to create symlink for rofi"
        exit 1
    fi
else
    echo "Cache file not found: $cache_file"
    exit 1
fi
