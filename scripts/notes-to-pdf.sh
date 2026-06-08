#!/usr/bin/env bash
# Usage: ./scripts/notes-to-pdf.sh docs/notes/day-N.md
# Converts a markdown file to a styled PDF with the same basename.
set -euo pipefail

if [ "$#" -ne 1 ]; then
  echo "Usage: $0 <input.md>" >&2
  exit 1
fi

INPUT="$1"
[ -f "$INPUT" ] || { echo "File not found: $INPUT" >&2; exit 1; }

OUTPUT="${INPUT%.md}.pdf"
TITLE="$(basename "${INPUT%.md}")"
TMPHTML="$(mktemp --suffix=.html)"
trap 'rm -f "$TMPHTML"' EXIT

BODY="$(marked --gfm -i "$INPUT")"

cat > "$TMPHTML" <<HTML
<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<title>${TITLE}</title>
<style>
  body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
         max-width: 780px; margin: 2em auto; padding: 0 1em; color: #1a1a1a; line-height: 1.6; }
  h1, h2, h3, h4 { font-weight: 600; margin-top: 1.6em; }
  h1 { border-bottom: 2px solid #333; padding-bottom: 0.3em; }
  h2 { border-bottom: 1px solid #ccc; padding-bottom: 0.2em; }
  code { background: #f4f4f4; padding: 0.1em 0.3em; border-radius: 3px; font-size: 0.9em; }
  pre { background: #2d2d2d; color: #f4f4f4; padding: 1em; border-radius: 5px; overflow-x: auto; }
  pre code { background: transparent; color: inherit; padding: 0; }
  table { border-collapse: collapse; margin: 1em 0; }
  th, td { border: 1px solid #ccc; padding: 0.5em 0.8em; text-align: left; vertical-align: top; }
  th { background: #f4f4f4; }
  blockquote { border-left: 4px solid #ccc; margin: 0; padding: 0 1em; color: #555; }
  hr { border: none; border-top: 1px solid #ddd; margin: 2em 0; }
  a { color: #0366d6; }
</style>
</head>
<body>
${BODY}
</body>
</html>
HTML

google-chrome --headless --no-sandbox --disable-gpu \
  --print-to-pdf="$OUTPUT" --print-to-pdf-no-header \
  "file://$TMPHTML" 2>/dev/null

echo "Wrote $OUTPUT"
