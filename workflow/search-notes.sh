#!/bin/bash
# Alfred Script Filter for Memoria search.
# Returns results as Alfred JSON format for live filtering.

MEMORIA=$(which memoria 2>/dev/null || echo "$HOME/go/bin/memoria")

QUERY="$1"

if [ -z "$QUERY" ]; then
    cat <<EOF
{"items":[{"title":"Type to search notes...","subtitle":"Search across all Memoria notes","valid":false}]}
EOF
    exit 0
fi

# Get search results as JSON
RESULTS=$("$MEMORIA" search "$QUERY" --json 2>&1)
EXIT_CODE=$?

if [ $EXIT_CODE -ne 0 ]; then
    cat <<EOF
{"items":[{"title":"Memoria not running","subtitle":"Start the Memoria TUI first","valid":false}]}
EOF
    exit 0
fi

# Convert Memoria JSON to Alfred Script Filter format using python3
echo "$RESULTS" | python3 -c "
import json, sys, re

def strip_html(text):
    return re.sub(r'<[^>]+>', '', text)

def truncate(text, maxlen=80):
    text = text.strip().replace('\n', ' ')
    text = re.sub(r'\s+', ' ', text)
    if len(text) > maxlen:
        return text[:maxlen] + '...'
    return text

try:
    results = json.load(sys.stdin)
except:
    print(json.dumps({'items': [{'title': 'No results', 'valid': False}]}))
    sys.exit(0)

if not results:
    print(json.dumps({'items': [{'title': 'No results found', 'subtitle': 'Try a different query', 'valid': False}]}))
    sys.exit(0)

items = []
for r in results[:20]:
    path = r.get('Path', '')
    fragments = r.get('Fragments', {})
    content_frags = fragments.get('content', [])

    subtitle = path
    if content_frags:
        # Clean up the fragment (strip HTML marks, ellipses)
        frag = strip_html(content_frags[0]).replace('…', '...')
        subtitle = truncate(frag)

    items.append({
        'title': path.replace('.md', '').replace('/', ' / '),
        'subtitle': subtitle,
        'arg': path,
        'autocomplete': path,
        'icon': {'path': 'icon.png'} if False else {},
        'text': {
            'copy': path,
            'largetype': path
        }
    })

print(json.dumps({'items': items}))
"
