#!/bin/bash
# Edit a cheatsheet in the Memoria TUI.
# Navigates to the note and activates the Memoria window.

MEMORIA=$(which memoria 2>/dev/null || echo "$HOME/go/bin/memoria")
NOTE_PATH="$1"

if [ -z "$NOTE_PATH" ]; then
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Navigate to the note in Memoria TUI
"$MEMORIA" navigate "$NOTE_PATH" 2>/dev/null

# Activate the Memoria window
source "$SCRIPT_DIR/activate-memoria.sh"
