#!/usr/bin/env bash
set -euo pipefail

YML_FILE="project.yml"

if [[ ! -f "$YML_FILE" ]]; then
  echo "Error: $YML_FILE not found in $(pwd)" >&2
  exit 1
fi

# Extract current value (assumes simple numeric CFBundleVersion with optional quotes)
CURRENT=$(awk '/CFBundleVersion:/ { v=$2; gsub(/"/,"",v); print v; exit }' "$YML_FILE")
if [[ -z "${CURRENT}" ]]; then
  echo "Error: CFBundleVersion not found in $YML_FILE" >&2
  exit 2
fi

if ! [[ "$CURRENT" =~ ^[0-9]+$ ]]; then
  echo "Error: CFBundleVersion is not a simple number: '$CURRENT'" >&2
  exit 3
fi

NEXT=$(( CURRENT + 1 ))

echo "Bumping CFBundleVersion: ${CURRENT} -> ${NEXT}"

# Replace line while preserving indentation and quoting style
awk -v newv="$NEXT" '
  /^\s*CFBundleVersion:/ {
    indent = match($0, /[^ ]/)-1
    # Try to detect existing quotes
    if ($0 ~ /CFBundleVersion:\s*"[0-9]+"/) {
      printf "%*sCFBundleVersion: \"%s\"\n", indent, "", newv
    } else {
      printf "%*sCFBundleVersion: %s\n", indent, "", newv
    }
    next
  }
  { print }
' "$YML_FILE" > "$YML_FILE.tmp" && mv "$YML_FILE.tmp" "$YML_FILE"

# Show result
NEW_VAL=$(awk '/CFBundleVersion:/ { v=$2; gsub(/"/,"",v); print v; exit }' "$YML_FILE")
echo "New CFBundleVersion in $YML_FILE: $NEW_VAL"
