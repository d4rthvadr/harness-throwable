#!/usr/bin/env bash
set -u

if [ "${COPILOT_STOP_HOOK_ACTIVE:-0}" = "1" ]; then
  exit 0
fi

export COPILOT_STOP_HOOK_ACTIVE=1

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

cd "$REPO_ROOT"

if [ -x "$REPO_ROOT/.venv/bin/python" ]; then
  "$REPO_ROOT/.venv/bin/python" -m pytest tests/ -x --tb=short 1>&2
else
  python -m pytest tests/ -x --tb=short 1>&2
fi
status=$?

if [ "$status" -ne 0 ]; then
  echo "Tests failed. Hook blocked further progress." >&2
  exit 2
fi

exit 0
