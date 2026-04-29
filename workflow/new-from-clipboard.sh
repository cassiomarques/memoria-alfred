#!/bin/bash
# Creates a new Memoria note from clipboard contents.
# Called by Alfred with {query} as the note name.

NOTE_NAME="${1:-clipboard-note}"
MEMORIA=$(which memoria 2>/dev/null || echo "$HOME/go/bin/memoria")

if ! command -v "$MEMORIA" &>/dev/null; then
    echo "memoria not found in PATH"
    exit 1
fi

# Read clipboard and pipe as content
CONTENT=$(pbpaste)

if [ -z "$CONTENT" ]; then
    echo "Clipboard is empty"
    exit 1
fi

OUTPUT=$(echo "$CONTENT" | "$MEMORIA" new "$NOTE_NAME" 2>&1)
EXIT_CODE=$?

if [ $EXIT_CODE -ne 0 ]; then
    echo "Error: $OUTPUT"
    exit 1
fi

echo "Created: $NOTE_NAME"
