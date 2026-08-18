#!/usr/bin/env bash
set -u

# Expected arguments: ToolName filepath
# Example: Write /path/to/file.py
if [ "$#" -lt 2 ]; then
  exit 0
fi

ToolName="$1"
filepath="$2"

timestamp="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
mkdir -p .logs
printf '%s %s: %s\n' "[$timestamp]" "$ToolName" "$filepath" >> .logs/edit-log.txt
exit 0
