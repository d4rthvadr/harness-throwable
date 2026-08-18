#!/usr/bin/env bash
set -u

if [ "${COPILOT_STOP_HOOK_ACTIVE:-0}" = "1" ]; then
  exit 0
fi

export COPILOT_STOP_HOOK_ACTIVE=1

pytest tests/ -x --tb=short 1>&2
status=$?

if [ "$status" -ne 0 ]; then
  echo "Tests failed. Hook blocked further progress." >&2
  exit 2
fi

exit 0
