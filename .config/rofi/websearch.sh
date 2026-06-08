#!/usr/bin/env bash
# rofi *script mode*: web search / URL opener via the DEFAULT browser.
#
#   rofi -show web -modi "web:~/.config/rofi/websearch.sh" -p search
#
# Type a query and press Enter -> opens a Google search in the default browser
# (xdg-open, which here resolves to google-chrome). If the text looks like a URL
# or a bare domain, it opens that page directly instead of searching.
#
# How the rofi script protocol works here:
#   - rofi calls this with NO args first -> we print one hint row.
#   - When you type text and press Enter, rofi passes that text as $1 (custom
#     entry), we open it, print nothing, and rofi closes.
set -u

HINT="Type a query or URL, then Enter"
query="${1:-}"

if [ -z "$query" ] || [ "$query" = "$HINT" ]; then
    echo "$HINT"          # first call (or hint selected with no typing): no-op
    exit 0
fi

if [[ "$query" =~ ^https?://[^[:space:]]+$ ]]; then
    url="$query"                                   # explicit URL
elif [[ "$query" =~ ^[A-Za-z0-9.-]+\.[A-Za-z]{2,}([/?#].*)?$ ]]; then
    url="https://$query"                           # bare domain -> add scheme
else
    enc=$(printf '%s' "$query" | jq -sRr @uri 2>/dev/null) || enc="$query"
    url="https://www.google.com/search?q=${enc}"   # web search
fi

setsid -f xdg-open "$url" >/dev/null 2>&1          # default browser, detached
exit 0
