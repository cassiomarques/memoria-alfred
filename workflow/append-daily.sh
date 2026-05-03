#!/bin/bash
# Appends a bullet item to today's section in the daily file.

MEMORIA=$(which memoria 2>/dev/null || echo "$HOME/go/bin/memoria")
TEXT="$1"

if [ -z "$TEXT" ]; then
    echo "No text provided"
    exit 1
fi

OUTPUT=$("$MEMORIA" daily "$TEXT" 2>&1)
EXIT_CODE=$?

if [ $EXIT_CODE -ne 0 ]; then
    echo "Error: $OUTPUT"
    exit 1
fi

echo "Added to daily log"
