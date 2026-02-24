#!/bin/bash
# Toggle TTS for Claude Code responses only
# Voice Control is managed separately via its own hotkey

TTS_FILE="$HOME/.claude/tts-enabled"

if [ -f "$TTS_FILE" ]; then
    rm "$TTS_FILE"
    killall say 2>/dev/null
    osascript -e 'display notification "TTS deaktiviert" with title "Claude Code"'
else
    touch "$TTS_FILE"
    osascript -e 'display notification "TTS aktiviert" with title "Claude Code"'
fi
