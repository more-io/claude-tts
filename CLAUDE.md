# Claude TTS — Developer Notes

## Files

| File | Hook Event | Purpose |
|------|------------|---------|
| `hooks/speak-response.sh` | `Stop` | Reads Claude's response aloud via `say` |
| `toggle-tts.sh` | — | Toggles TTS on/off (flag file + notification) |
| `play-sound.sh` | `UserPromptSubmit` | Plays a macOS system sound |

## Key Design Decisions

- **Language prefix protocol**: Claude prefixes responses with `DE:` or `EN:`. The hook reads this prefix, strips it, and selects the voice. Fallback: German.
- **Flag file toggle**: `~/.claude/tts-enabled` — presence means on, absence means off. No config files, no state to corrupt.
- **Python cleanup**: Inline Python in the shell script strips markdown, code blocks, URLs, and file paths before passing to `say`. Keeps the script self-contained (no external dependencies beyond Python 3).
- **Background `say`**: The `say` command runs with `&` so the hook returns immediately and doesn't block Claude Code.
- **`killall say`**: Previous speech is killed before new speech starts to prevent overlap.

## Testing

```bash
# Test speak-response with a mock Stop hook payload
echo '{"last_assistant_message":"DE: Das ist ein Test."}' | bash hooks/speak-response.sh

# Test English voice
echo '{"last_assistant_message":"EN: This is a test."}' | bash hooks/speak-response.sh

# Test toggle
bash toggle-tts.sh   # notification appears

# Test sounds
bash play-sound.sh glass
bash play-sound.sh pop
```

## Configuration

- **Speech rate**: `-r 210` in `hooks/speak-response.sh` (words per minute)
- **English voice**: `Evan (Enhanced)` — change in `hooks/speak-response.sh`
- **German voice**: System default — configure in macOS System Settings > Accessibility > Spoken Content
