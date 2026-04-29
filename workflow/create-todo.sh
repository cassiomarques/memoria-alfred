#!/bin/bash
# Creates a new Memoria todo.
# Called by Alfred with {query} as the full todo input.
# Parses --due and --tags flags from the input.

MEMORIA=$(which memoria 2>/dev/null || echo "$HOME/go/bin/memoria")

if ! command -v "$MEMORIA" &>/dev/null; then
    echo "memoria not found in PATH"
    exit 1
fi

INPUT="$1"

if [ -z "$INPUT" ]; then
    echo "No todo title provided"
    exit 1
fi

# Parse flags from input
TITLE_PARTS=()
DUE=""
TAGS=""
FOLDER=""

# Split input into words
read -ra WORDS <<< "$INPUT"

i=0
while [ $i -lt ${#WORDS[@]} ]; do
    case "${WORDS[$i]}" in
        --due)
            i=$((i + 1))
            # Collect due value (may be multi-word like "2 weeks")
            DUE="${WORDS[$i]}"
            # Check if next word is a unit (days/weeks/months)
            if [ $((i + 1)) -lt ${#WORDS[@]} ]; then
                next="${WORDS[$((i + 1))]}"
                case "$next" in
                    day|days|week|weeks|month|months)
                        DUE="$DUE $next"
                        i=$((i + 1))
                        ;;
                esac
            fi
            ;;
        --tags)
            i=$((i + 1))
            TAGS="${WORDS[$i]}"
            ;;
        --folder)
            i=$((i + 1))
            FOLDER="${WORDS[$i]}"
            ;;
        *)
            TITLE_PARTS+=("${WORDS[$i]}")
            ;;
    esac
    i=$((i + 1))
done

TITLE="${TITLE_PARTS[*]}"

if [ -z "$TITLE" ]; then
    echo "No todo title provided"
    exit 1
fi

# Build command
CMD=("$MEMORIA" todo "$TITLE")

if [ -n "$DUE" ]; then
    CMD+=(--due "$DUE")
fi
if [ -n "$TAGS" ]; then
    CMD+=(--tags "$TAGS")
fi
if [ -n "$FOLDER" ]; then
    CMD+=(--folder "$FOLDER")
fi

OUTPUT=$("${CMD[@]}" 2>&1)
EXIT_CODE=$?

if [ $EXIT_CODE -ne 0 ]; then
    echo "Error: $OUTPUT"
    exit 1
fi

echo "Todo created: $TITLE"
