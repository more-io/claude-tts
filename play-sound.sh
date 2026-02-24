#!/bin/bash
# Play a macOS system sound in the background
# Usage: play-sound.sh [glass|pop|ping|...]
SOUND="${1:-glass}"
case "$SOUND" in
    glass)   afplay /System/Library/Sounds/Glass.aiff ;;
    pop)     afplay /System/Library/Sounds/Pop.aiff ;;
    ping)    afplay /System/Library/Sounds/Ping.aiff ;;
    hero)    afplay /System/Library/Sounds/Hero.aiff ;;
    *)       afplay "/System/Library/Sounds/${SOUND}.aiff" ;;
esac
