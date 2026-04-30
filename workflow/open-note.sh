#!/bin/bash
# Opens a note in the running Memoria TUI by navigating to it
# and switching to the iTerm/tmux window.
# If neovim is open (editing a note), closes it first so Memoria resumes.

MEMORIA=$(which memoria 2>/dev/null || echo "$HOME/go/bin/memoria")
NVIM_SOCK="/tmp/memoria-nvim.sock"
NOTE_PATH="$1"

if [ -z "$NOTE_PATH" ]; then
    echo "No note path provided"
    exit 1
fi

# If neovim is running via Memoria, save and quit it first.
# This lets Memoria resume its TUI before we send the navigate command.
if [ -S "$NVIM_SOCK" ]; then
    nvim --server "$NVIM_SOCK" --remote-send '<C-\><C-n>:wqa<CR>' 2>/dev/null
    # Wait for neovim to exit and Memoria to resume
    for i in $(seq 1 20); do
        [ ! -S "$NVIM_SOCK" ] && break
        sleep 0.1
    done
fi

# Tell the TUI to navigate to this note
OUTPUT=$("$MEMORIA" navigate "$NOTE_PATH" 2>&1)
EXIT_CODE=$?

if [ $EXIT_CODE -ne 0 ]; then
    echo "Error: $OUTPUT"
    exit 1
fi

# Activate iTerm and switch to the tmux "memoria" window
DIR="$(cd "$(dirname "$0")" && pwd)"
bash "$DIR/activate-memoria.sh"

echo "Opened: $NOTE_PATH"
