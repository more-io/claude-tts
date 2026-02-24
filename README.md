# Claude Code TTS

![Platform: macOS](https://img.shields.io/badge/Platform-macOS-lightgrey.svg)
![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)

Automatic text-to-speech for [Claude Code](https://claude.ai/claude-code) responses — reads Claude's answers aloud using macOS `say`, with automatic language detection, markdown cleanup, and a hotkey toggle.

---

## How It Works

Claude prefixes every response with `DE:` or `EN:`. A Claude Code `Stop` hook fires after each response, pipes the last message through a Python cleanup step (strips code blocks, URLs, markdown), and reads the result aloud with the right voice.

```
Claude responds → Stop hook fires → language detected → markdown stripped → say speaks it
```

- **German (`DE:`)** — uses the system default voice (configure in System Settings → Accessibility → Spoken Content)
- **English (`EN:`)** — uses `Evan (Enhanced)` voice (configurable)
- **Toggle** — `tts-enabled` file acts as on/off flag; hotkey can flip it instantly
- **Sound notifications** — `play-sound.sh` plays system sounds on events (e.g. Pop when user submits a message)

---

## Setup

### 1. Copy scripts

```bash
git clone https://github.com/more-io/claude-tts.git
cd claude-tts

# Create hooks directory if needed
mkdir -p ~/.claude/hooks

cp hooks/speak-response.sh ~/.claude/hooks/speak-response.sh
cp toggle-tts.sh ~/.claude/toggle-tts.sh
cp play-sound.sh ~/.claude/play-sound.sh

chmod +x ~/.claude/hooks/speak-response.sh
chmod +x ~/.claude/toggle-tts.sh
chmod +x ~/.claude/play-sound.sh
```

### 2. Register hooks in Claude Code

Add to `~/.claude/settings.json`:

```json
{
  "hooks": {
    "Stop": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "bash ~/.claude/hooks/speak-response.sh"
          }
        ]
      }
    ],
    "UserPromptSubmit": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "bash ~/.claude/play-sound.sh pop"
          }
        ]
      }
    ]
  }
}
```

### 3. Enable TTS

```bash
touch ~/.claude/tts-enabled
```

That's it — Claude will now speak its responses aloud.

### 4. Optional: Toggle hotkey via macOS Shortcuts

You can toggle TTS with a keyboard shortcut using the macOS Shortcuts app:

1. Open **Shortcuts.app** and create a new shortcut
2. Name it **Claude TTS Toggle**
3. Add a **"Run Shell Script"** action with these settings:
   - **Script**: `~/.claude/toggle-tts.sh`
   - **Shell**: `bash`
   - **Input**: `Eingabe` / `Input`
   - **Pass input**: `an stdin` / `to stdin`
4. Go to **System Settings → Keyboard → Keyboard Shortcuts → App Shortcuts** (or assign directly in Shortcuts.app)
5. Assign a hotkey (e.g. `⌃⌥T`)

<img src="docs/shortcut-setup.png" width="600" alt="macOS Shortcuts setup for Claude TTS Toggle">

A macOS notification ("TTS aktiviert" / "TTS deaktiviert") confirms each toggle.

---

## Configuration

### Speech rate

Edit `hooks/speak-response.sh` and change the `-r` value (words per minute):

```bash
echo "$TEXT" | say -r 210 &                         # German
echo "$TEXT" | say -v "Evan (Enhanced)" -r 210 &    # English
```

### English voice

Change `Evan (Enhanced)` to any installed voice:

```bash
say -v '?'   # list all available voices
```

### German voice

The best German voices (Siri voices) are **not** selectable via `say -v` — they can only be set as the system default voice:

1. Go to **System Settings → Accessibility → Spoken Content → System Voice**
2. Click the dropdown and select **German** as language
3. Download a high-quality voice if not already installed (e.g. "Siri Voice 1" or "Siri Voice 2" — these are optional downloads, ~100-150 MB each)
4. Set the downloaded Siri voice as system voice

The `say` command without `-v` flag automatically uses whatever system voice you configured here. That's why `speak-response.sh` uses plain `say` for German (no `-v` parameter) — it picks up the Siri voice from system settings.

> **Note**: The built-in non-Siri German voices (Anna, Petra, etc.) are lower quality. Downloading a Siri voice makes a significant difference for German speech output.

---

## Language Prefix Protocol

Claude must prefix every response with `DE:` or `EN:` as the very first characters. Add this instruction to your global `~/.claude/CLAUDE.md`:

```markdown
### Language Prefix (MANDATORY)
- **ALWAYS** prefix every response with `DE:` or `EN:` as the very first characters
- `DE:` for German responses, `EN:` for English responses
- The prefix is stripped before speaking and selects the correct voice
```

Without the prefix the hook defaults to German.

---

## Files

| File | Purpose |
|------|---------|
| `hooks/speak-response.sh` | `Stop` hook — reads Claude's response aloud |
| `toggle-tts.sh` | Toggles TTS on/off, shows macOS notification |
| `play-sound.sh` | Plays a named macOS system sound (`glass`, `pop`, `ping`, `hero`) |

The toggle uses `~/.claude/tts-enabled` as a flag file — present means on, absent means off.

---

## What Gets Cleaned Before Speaking

The Python cleanup step in `speak-response.sh` strips:

- Fenced code blocks (` ``` ... ``` `)
- Inline code (but keeps the text inside)
- URLs (`https://...`)
- File paths (`/Users/...`)
- Markdown headers, bold/italic markers
- Markdown links (keeps display text)
- Bullet and numbered list markers
- Pipe tables
- Horizontal rules

Very short messages (under 5 characters) are skipped entirely.

---

## Requirements

- macOS (uses `say` and `afplay`)
- Python 3 (pre-installed on macOS)
- Claude Code with hooks support

---

## License

MIT — see [LICENSE](LICENSE) for details.
