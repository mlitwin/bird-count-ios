#!/usr/bin/env bash
set -euo pipefail

YML_FILE="project.yml"

# Test if there are any uncommitted changes
if ! git diff --quiet; then
  echo "Error: Uncommitted changes found in $(pwd)" >&2
  exit 1
fi

if [[ ! -f "$YML_FILE" ]]; then
  echo "Error: $YML_FILE not found in $(pwd)" >&2
  exit 1
fi

# Extract current value (assumes simple numeric CFBundleVersion with optional quotes)
CURRENT=$(awk '/CFBundleVersion:[[:space:]]*/ { v=$2; gsub(/"/,"",v); print v; exit }' "$YML_FILE")
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

# Replace line while preserving leading whitespace and quoting style
awk -v newv="$NEXT" '
  /^[[:space:]]*CFBundleVersion:/ {
    # capture original leading whitespace (spaces/tabs)
    match($0, /^[[:space:]]*/)
    lead = substr($0, 1, RLENGTH)
    # detect existing quotes
    if ($0 ~ /CFBundleVersion:[[:space:]]*"[0-9]+"/) {
      printf "%sCFBundleVersion: \"%s\"\n", lead, newv
    } else {
      printf "%sCFBundleVersion: %s\n", lead, newv
    }
    next
  }
  { print }
' "$YML_FILE" > "$YML_FILE.tmp" && mv "$YML_FILE.tmp" "$YML_FILE"

# Show result
NEW_VAL=$(awk '/CFBundleVersion:[[:space:]]*/ { v=$2; gsub(/"/,"",v); print v; exit }' "$YML_FILE")
echo "New CFBundleVersion in $YML_FILE: $NEW_VAL"

# Extract CFBundleShortVersionString for tagging (e.g., 1.2.3)
SHORT_VER=$(awk '/CFBundleShortVersionString:/ { v=$2; gsub(/"/,"",v); print v; exit }' "$YML_FILE")
if [[ -z "${SHORT_VER}" ]]; then
  echo "Warning: CFBundleShortVersionString not found in $YML_FILE; skipping git tag" >&2
  exit 0
fi

# Create git tag v<short>-<build> on current HEAD
TAG="v${SHORT_VER}-${NEW_VAL}"

# Commit current changes
git commit -m "Bump CFBundleVersion: ${CURRENT} -> ${NEXT}"
git tag -a "${TAG}" -m "Release ${SHORT_VER} (${NEW_VAL})"