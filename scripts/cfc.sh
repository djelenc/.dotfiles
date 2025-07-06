#!/usr/bin/env bash
# copies file contents and filename to clipboard
set -euo pipefail

# enable ** recursion and drop unmatched patterns
shopt -s globstar nullglob

buffer=""

for pattern in "$@"; do
  files=($pattern)
  if ((${#files[@]} == 0)); then
    echo "Warning: pattern '$pattern' did not match any files" >&2
    continue
  fi

  for file in "${files[@]}"; do
    if [[ -f "$file" ]]; then
      # compute path relative to CWD
      if command -v realpath &>/dev/null; then
        relpath=$(realpath --relative-to="$PWD" "$file")
      else
        # strip leading $PWD/ if present, else leave as-is
        relpath="${file/#"$PWD\/"/}"
      fi

      buffer+="# file: $relpath"$'\n'
      buffer+="\`\`\`"$'\n'
      buffer+="$(<"$file")"$'\n'
      buffer+="\`\`\`"$'\n'
    else
      echo "Warning: '$file' is not a regular file, skipping" >&2
    fi
  done
done

copy_to_clipboard() {
  if command -v pbcopy &>/dev/null; then
    printf '%s' "$buffer" | pbcopy
  elif command -v xclip &>/dev/null; then
    printf '%s' "$buffer" | xclip -selection clipboard
  elif command -v xsel &>/dev/null; then
    printf '%s' "$buffer" | xsel --clipboard --input
  elif command -v wl-copy &>/dev/null; then
    printf '%s' "$buffer" | wl-copy
  else
    return 1
  fi
}

if ! copy_to_clipboard; then
  printf '%s' "$buffer"
  echo "Error: no clipboard utility found. Install pbcopy (mac), xclip, xsel or wl-clipboard." >&2
  exit 1
fi
