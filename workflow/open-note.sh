#!/bin/bash
# Opens a note in the running Memoria TUI by navigating to it
# and switching to the iTerm/tmux window.

MEMORIA=$(which memoria 2>/dev/null || echo "$HOME/go/bin/memoria")
NOTE_PATH="$1"

if [ -z "$NOTE_PATH" ]; then
    echo "No note path provided"
    exit 1
fi

# Tell the TUI to navigate to this note
OUTPUT=$("$MEMORIA" navigate "$NOTE_PATH" 2>&1)
EXIT_CODE=$?

if [ $EXIT_CODE -ne 0 ]; then
    echo "Error: $OUTPUT"
    exit 1
fi

# Activate iTerm and switch to the tmux "notes" window
osascript -e 'tell application "iTerm" to activate'

# Small delay to ensure iTerm is focused
sleep 0.1

# Switch tmux to the "notes" window
# Use -t to target the session:window by name
tmux select-window -t notes 2>/dev/null

echo "Opened: $NOTE_PATH"
