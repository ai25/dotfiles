#!/bin/bash

# Direct mouse press/release script with logging
# Usage: script.sh press|release

LOG_FILE="/tmp/wtype_debug.log"

log_action() {
    echo "$(date): $1" >> "$LOG_FILE"
}

case "${1:-press}" in
    "press")
        log_action "PRESS command executed"
        wtype -B left
        if [ $? -eq 0 ]; then
            log_action "PRESS successful"
        else
            log_action "PRESS failed with exit code $?"
        fi
        ;;
    "release")
        log_action "RELEASE command executed"
        sleep 0.01  # Small delay to ensure proper timing
        wtype -b left
        if [ $? -eq 0 ]; then
            log_action "RELEASE successful"
        else
            log_action "RELEASE failed with exit code $?"
        fi
        ;;
    "status")
        if [ -f "$LOG_FILE" ]; then
            tail -10 "$LOG_FILE"
        else
            echo "No log file found"
        fi
        ;;
    "clear")
        rm -f "$LOG_FILE"
        echo "Log cleared"
        ;;
    *)
        echo "Usage: $0 {press|release|status|clear}"
        exit 1
        ;;
esac
