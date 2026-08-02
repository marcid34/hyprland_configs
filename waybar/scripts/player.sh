#!/bin/bash
# Get playback status (Playing, Paused, etc.)
status=$(playerctl status 2>/dev/null)

if [ "$status" = "Playing" ]; then
    # Extract title and artist from browser MPRIS data
    title=$(playerctl metadata xesam:title)
    artist=$(playerctl metadata xesam:artist)
    
    # Fallback if artist field is empty (common on standard YouTube)
    if [ -z "$artist" ]; then
        text="$title"
    else
        text="$artist - $title"
    fi
    
    # Output JSON format required by Waybar
    jq -cn --arg text "$text" --arg class "$status" '{"text": $text, "class": $class}'
else
    # Output empty JSON when nothing is playing to hide the module
    echo '{"text": "", "class": "stopped"}'
fi

