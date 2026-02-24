#!/bin/bash
# Speak Claude's text responses aloud with language prefix detection
# Claude prefixes responses with "DE:" or "EN:" for reliable language selection
# Toggle: touch ~/.claude/tts-enabled to enable, rm to disable

# Check if TTS is enabled
[ ! -f "$HOME/.claude/tts-enabled" ] && exit 0

# Kill any previous say process to avoid overlap
killall say 2>/dev/null

# Read stdin (JSON from Claude Code Stop hook)
INPUT=$(cat)

# Extract, clean the message, and detect language from prefix
RESULT=$(echo "$INPUT" | python3 -c "
import sys, json, re

data = json.load(sys.stdin)
msg = data.get('last_assistant_message', '')
if not msg:
    sys.exit(0)

# Detect language from prefix (DE: or EN: at the start)
lang = 'de'  # default to German
stripped = msg.strip()
if stripped.upper().startswith('EN:'):
    lang = 'en'
    msg = stripped[3:].strip()
elif stripped.upper().startswith('DE:'):
    lang = 'de'
    msg = stripped[3:].strip()

# Remove code blocks (\`\`\` ... \`\`\`)
msg = re.sub(r'\x60\x60\x60[\s\S]*?\x60\x60\x60', '', msg)

# Remove inline code backticks but keep the text inside
msg = re.sub(r'\x60([^\x60]+)\x60', r'\1', msg)

# Remove URLs
msg = re.sub(r'https?://\S+', '', msg)

# Remove file paths (e.g. /Users/tobias/...)
msg = re.sub(r'(?<!\w)/[\w./-]+', '', msg)

# Remove markdown header markers but keep text
msg = re.sub(r'^#{1,6}\s+', '', msg, flags=re.MULTILINE)

# Remove bold/italic markers but keep text
msg = re.sub(r'\*{1,3}([^*]+)\*{1,3}', r'\1', msg)

# Remove markdown links, keep display text
msg = re.sub(r'\[([^\]]+)\]\([^)]+\)', r'\1', msg)

# Remove bullet markers
msg = re.sub(r'^[\s]*[-*]\s+', '', msg, flags=re.MULTILINE)

# Remove numbered list markers
msg = re.sub(r'^\d+\.\s+', '', msg, flags=re.MULTILINE)

# Remove pipe tables
msg = re.sub(r'^\|.*\|$', '', msg, flags=re.MULTILINE)

# Remove horizontal rules
msg = re.sub(r'^-{3,}$', '', msg, flags=re.MULTILINE)

# Clean up excessive whitespace
msg = re.sub(r'\n{3,}', '\n\n', msg)
msg = msg.strip()

# Skip very short messages (e.g. just 'Ok')
if len(msg) < 5:
    sys.exit(0)

# Output language on first line, text on remaining lines
print(lang)
print(msg)
")

if [ -n "$RESULT" ]; then
    LANG=$(echo "$RESULT" | head -1)
    TEXT=$(echo "$RESULT" | tail -n +2)

    if [ -n "$TEXT" ]; then
        if [ "$LANG" = "de" ]; then
            echo "$TEXT" | say -r 210 &
        else
            echo "$TEXT" | say -v "Evan (Enhanced)" -r 210 &
        fi
    fi
fi

exit 0
