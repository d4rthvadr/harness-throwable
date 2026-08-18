#!/usr/bin/env bash
set -u

# Hook runtime may pass the tool name and target path as args.
# Ignore all other tool events and only log Write/Edit actions.
if [ "$#" -lt 2 ]; then
  exit 0
fi

ToolName="$1"
filepath="$2"

if [[ "$ToolName" != "Write" && "$ToolName" != "Edit" ]]; then
  exit 0
fi

timestamp="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
mkdir -p .logs
printf '%s %s: %s\n' "[$timestamp]" "$ToolName" "$filepath" >> .logs/edit-log.txt
exit 0
