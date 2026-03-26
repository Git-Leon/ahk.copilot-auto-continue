# copilot-auto-continue

AutoHotkey script that keeps GitHub Copilot Agent mode running by:
- sending `Ctrl+Enter` every 10 seconds
- periodically sending "Continue" to bypass iteration limits

## Usage
- Run script
- Toggle with Ctrl+Alt+G
- Keep VS Code focused

## Motivation
Prevents Copilot from pausing during long-running agent tasks.

Ensure copilot-auto-continue.ahk is ran as administrator