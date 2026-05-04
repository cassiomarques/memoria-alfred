#!/bin/bash
# Alfred action: append an entry to a cheatsheet table.
# Input format: <cheatsheet>::<section>::<col1>::<col2>[::col3...]
# Example: git::Basics::`git diff`::Show unstaged changes
#
# Keyword: mca

MEMORIA=$(which memoria 2>/dev/null || echo "/opt/homebrew/bin/memoria")
INPUT="$1"

if [ -z "$INPUT" ]; then
    exit 1
fi

# Parse input using :: as delimiter
IFS='::' read -ra PARTS <<< "$INPUT"

# Filter out empty parts (IFS splits on each char, so :: produces empty elements)
ARGS=()
for part in "${PARTS[@]}"; do
    if [ -n "$part" ]; then
        ARGS+=("$part")
    fi
done

if [ ${#ARGS[@]} -lt 4 ]; then
    osascript -e 'display notification "Format: name::section::col1::col2" with title "Memoria" subtitle "Not enough arguments"'
    exit 1
fi

CHEATSHEET="${ARGS[0]}"
SECTION="${ARGS[1]}"
COLUMNS=("${ARGS[@]:2}")

# Build the command — wrap first column in backticks if not already wrapped
FIRST_COL="${COLUMNS[0]}"
if [[ ! "$FIRST_COL" == \`* ]]; then
    COLUMNS[0]="\`${FIRST_COL}\`"
fi

# Call memoria cheatsheet-add
"$MEMORIA" cheatsheet-add "cheatsheets/${CHEATSHEET}.md" "$SECTION" "${COLUMNS[@]}" 2>/tmp/memoria-mca-debug.log

if [ $? -eq 0 ]; then
    osascript -e "display notification \"Added to ${SECTION}\" with title \"Memoria\" subtitle \"${CHEATSHEET} cheatsheet\""
else
    ERROR=$(cat /tmp/memoria-mca-debug.log)
    osascript -e "display notification \"${ERROR}\" with title \"Memoria\" subtitle \"Error\""
fi
