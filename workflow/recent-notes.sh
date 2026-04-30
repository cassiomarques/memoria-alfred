#!/bin/bash
# Alfred Script Filter: lists recently modified notes from Memoria.
# Returns results in Alfred JSON format, most recent first.

MEMORIA=$(which memoria 2>/dev/null || echo "$HOME/go/bin/memoria")
LIMIT="${1:-10}"

# Get recent notes as JSON from Memoria
RESULTS=$("$MEMORIA" recent "$LIMIT" --json 2>/dev/null)

if [ $? -ne 0 ] || [ -z "$RESULTS" ]; then
    echo '{"items":[{"title":"Memoria is not running","subtitle":"Start the TUI first","valid":false}]}'
    exit 0
fi

# Transform to Alfred JSON format
echo "$RESULTS" | python3 -c "
import json, sys, os
from datetime import datetime

data = json.load(sys.stdin)
items = []
for note in data:
    path = note.get('Path', '')
    title = note.get('Title', os.path.basename(path))
    folder = note.get('Folder', '')
    modified = note.get('Modified', '')

    # Format relative time
    subtitle = folder
    if modified:
        try:
            # Parse ISO timestamp
            dt = datetime.fromisoformat(modified.replace('Z', '+00:00'))
            now = datetime.now(dt.tzinfo) if dt.tzinfo else datetime.now()
            diff = now - dt
            if diff.days == 0:
                hours = diff.seconds // 3600
                if hours == 0:
                    mins = diff.seconds // 60
                    age = f'{mins}m ago' if mins > 0 else 'just now'
                else:
                    age = f'{hours}h ago'
            elif diff.days == 1:
                age = 'yesterday'
            elif diff.days < 7:
                age = f'{diff.days}d ago'
            else:
                age = dt.strftime('%b %d')
            subtitle = f'{age} · {folder}' if folder else age
        except:
            pass

    items.append({
        'title': title,
        'subtitle': subtitle,
        'arg': path,
        'valid': True,
        'icon': {'path': 'icon.png'} if os.path.exists('icon.png') else {}
    })

print(json.dumps({'items': items}))
"
