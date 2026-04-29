#!/bin/bash
# Creates a new Memoria todo.
# Called by Alfred with {query} as the full todo input.
# Supports both TUI syntax (@due(), #tag) and CLI flags (--due, --tags).

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
TAGS=()
FOLDER=""

# Split input into words
read -ra WORDS <<< "$INPUT"

i=0
while [ $i -lt ${#WORDS[@]} ]; do
    word="${WORDS[$i]}"
    case "$word" in
        --due)
            i=$((i + 1))
            DUE="${WORDS[$i]}"
            # Check if next word is a time unit
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
        @due\(*)
            # Handle @due(...) — collect tokens until closing )
            due_content="${word#@due(}"
            if [[ "$due_content" == *")" ]]; then
                # Single token: @due(2026-05-01)
                DUE="${due_content%)}"
            else
                # Multi-token: @due(2 weeks)
                DUE="$due_content"
                i=$((i + 1))
                while [ $i -lt ${#WORDS[@]} ]; do
                    if [[ "${WORDS[$i]}" == *")" ]]; then
                        DUE="$DUE ${WORDS[$i]%)}";
                        break
                    fi
                    DUE="$DUE ${WORDS[$i]}"
                    i=$((i + 1))
                done
            fi
            ;;
        --tags)
            i=$((i + 1))
            IFS=',' read -ra TAG_LIST <<< "${WORDS[$i]}"
            TAGS+=("${TAG_LIST[@]}")
            ;;
        \#*)
            # Handle #tag syntax
            tag="${word#\#}"
            if [ -n "$tag" ]; then
                TAGS+=("$tag")
            fi
            ;;
        --folder)
            i=$((i + 1))
            FOLDER="${WORDS[$i]}"
            ;;
        *)
            TITLE_PARTS+=("$word")
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
if [ ${#TAGS[@]} -gt 0 ]; then
    TAG_STR=$(IFS=,; echo "${TAGS[*]}")
    CMD+=(--tags "$TAG_STR")
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

