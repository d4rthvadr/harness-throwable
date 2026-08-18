#!/usr/bin/env bash
set -u

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

HOST="${HOST:-127.0.0.1}"
PORT="${PORT:-8001}"
BASE_URL="http://${HOST}:${PORT}"
VENV_PYTHON="${ROOT_DIR}/.venv/bin/python"
LOG_FILE="${ROOT_DIR}/.logs/check-health.log"

mkdir -p "$(dirname "$LOG_FILE")"

cleanup() {
  if [[ -n "${SERVER_PID:-}" ]] && kill -0 "$SERVER_PID" 2>/dev/null; then
    kill "$SERVER_PID" 2>/dev/null || true
    wait "$SERVER_PID" 2>/dev/null || true
  fi
}
trap cleanup EXIT

run_check() {
  local label="$1"
  local path="$2"
  local validator="$3"
  local body

  if ! body="$(curl -fsS "${BASE_URL}${path}" 2>/dev/null)"; then
    echo "FAIL: ${label} (${path})"
    return 1
  fi

  if ! printf '%s' "$body" | "$VENV_PYTHON" -c "$validator" >/dev/null 2>&1; then
    echo "FAIL: ${label} (${path})"
    return 1
  fi

  echo "PASS: ${label} (${path})"
}

if [[ ! -x "$VENV_PYTHON" ]]; then
  echo "FAIL: Python venv not found at ${VENV_PYTHON}"
  exit 1
fi

"$VENV_PYTHON" -m uvicorn app.main:app --host "$HOST" --port "$PORT" > "$LOG_FILE" 2>&1 &
SERVER_PID=$!

for _ in $(seq 1 30); do
  if curl -fsS "${BASE_URL}/" >/dev/null 2>&1; then
    break
  fi

  if ! kill -0 "$SERVER_PID" 2>/dev/null; then
    echo "FAIL: uvicorn exited during startup"
    cat "$LOG_FILE"
    exit 1
  fi

  sleep 1
done

if ! curl -fsS "${BASE_URL}/" >/dev/null 2>&1; then
  echo "FAIL: server did not become ready"
  cat "$LOG_FILE"
  exit 1
fi

status=0

run_check "root endpoint" "/" "import json,sys; data=json.load(sys.stdin); assert data.get('message') == 'Bookshelf API'" || status=1
run_check "books list endpoint" "/books/" "import json,sys; data=json.load(sys.stdin); assert isinstance(data, list)" || status=1
run_check "book count endpoint" "/books/count" "import json,sys; data=json.load(sys.stdin); assert isinstance(data.get('count'), int) and data['count'] >= 0" || status=1

if [[ "$status" -ne 0 ]]; then
  exit 1
fi

printf '\nHealth check summary: PASS\n'
