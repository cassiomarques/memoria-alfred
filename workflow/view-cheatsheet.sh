#!/bin/bash
# View a cheatsheet as a QuickLook overlay.
# Gets the note content, converts to styled HTML with pandoc, opens with QuickLook.

MEMORIA=$(which memoria 2>/dev/null || echo "$HOME/go/bin/memoria")
PANDOC=$(which pandoc 2>/dev/null || echo "/opt/homebrew/bin/pandoc")
NOTE_PATH="$1"

if [ -z "$NOTE_PATH" ]; then
    exit 1
fi

# Get note content via Memoria
CONTENT=$("$MEMORIA" cat "$NOTE_PATH" 2>/dev/null)
if [ $? -ne 0 ] || [ -z "$CONTENT" ]; then
    osascript -e 'display notification "Could not read cheatsheet" with title "Memoria"'
    exit 1
fi

# Strip YAML frontmatter if present (everything between first --- and next ---)
if echo "$CONTENT" | head -1 | grep -q '^---$'; then
    BODY=$(echo "$CONTENT" | awk '
        BEGIN { in_fm=0; past_fm=0 }
        /^---$/ {
            if (!past_fm) {
                if (in_fm) { past_fm=1; next }
                else { in_fm=1; next }
            }
        }
        past_fm { print }
    ')
else
    BODY="$CONTENT"
fi

# Get the CSS file path (bundled in workflow)
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CSS_FILE="$SCRIPT_DIR/cheatsheet.css"

# Convert to HTML with pandoc
TMPFILE="/tmp/memoria-cheatsheet.html"
echo "$BODY" | "$PANDOC" --standalone -t html5 \
    --metadata title="" \
    --css "$CSS_FILE" \
    --embed-resources \
    -o "$TMPFILE" 2>/dev/null

if [ $? -ne 0 ]; then
    # Fallback: simple HTML wrapping
    echo "<html><head><style>$(cat "$CSS_FILE" 2>/dev/null)</style></head><body><pre>$BODY</pre></body></html>" > "$TMPFILE"
fi

# Open with QuickLook and bring to front
qlmanage -p "$TMPFILE" &>/dev/null &
sleep 0.5
osascript -e 'tell application "System Events" to set frontmost of process "qlmanage" to true' 2>/dev/null
