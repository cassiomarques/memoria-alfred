#!/bin/bash
# Alfred Script Filter: lists cheatsheets from Memoria.
# Keyword: mcs — returns results in Alfred JSON format.

MEMORIA=$(which memoria 2>/dev/null || echo "$HOME/go/bin/memoria")

# Get cheatsheets as JSON
RESULTS=$("$MEMORIA" cheatsheets --json 2>/dev/null)

if [ $? -ne 0 ] || [ -z "$RESULTS" ]; then
    echo '{"items":[{"title":"Memoria is not running","subtitle":"Start the TUI first","valid":false}]}'
    exit 0
fi

# Transform to Alfred JSON format
echo "$RESULTS" | python3 -c "
import json, sys, os

data = json.load(sys.stdin)

if not data:
    print(json.dumps({'items': [{'title': 'No cheatsheets found', 'subtitle': 'Create notes with cheatsheet: true in frontmatter', 'valid': False}]}))
    sys.exit(0)

items = []
for note in data:
    path = note.get('Path', '')
    title = note.get('Title', os.path.basename(path).replace('.md', ''))
    folder = note.get('Folder', '')

    subtitle = folder if folder else 'cheatsheets'

    items.append({
        'title': title,
        'subtitle': subtitle,
        'arg': path,
        'valid': True,
        'mods': {
            'cmd': {
                'arg': path,
                'subtitle': 'Edit in Memoria TUI',
                'valid': True
            }
        }
    })

print(json.dumps({'items': items}))
"
