#!/usr/bin/env bash
set -u

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

HOST="${HOST:-127.0.0.1}"
PORT="${PORT:-8001}"
BASE_URL="http://${HOST}:${PORT}"
VENV_PYTHON="${ROOT_DIR}/.venv/bin/python"
LOG_FILE="${ROOT_DIR}/.logs/check-schema.log"

mkdir -p "$(dirname "$LOG_FILE")"

cleanup() {
  if [[ -n "${SERVER_PID:-}" ]] && kill -0 "$SERVER_PID" 2>/dev/null; then
    kill "$SERVER_PID" 2>/dev/null || true
    wait "$SERVER_PID" 2>/dev/null || true
  fi
}
trap cleanup EXIT

if [[ ! -x "$VENV_PYTHON" ]]; then
  echo "FAIL: Python venv not found at ${VENV_PYTHON}"
  exit 1
fi

"$VENV_PYTHON" -m uvicorn app.main:app --host "$HOST" --port "$PORT" > "$LOG_FILE" 2>&1 &
SERVER_PID=$!

for _ in $(seq 1 30); do
  if curl -fsS "${BASE_URL}/openapi.json" >/dev/null 2>&1; then
    break
  fi

  if ! kill -0 "$SERVER_PID" 2>/dev/null; then
    echo "FAIL: uvicorn exited during startup"
    cat "$LOG_FILE"
    exit 1
  fi

  sleep 1
done

if ! curl -fsS "${BASE_URL}/openapi.json" >/dev/null 2>&1; then
  echo "FAIL: server did not become ready"
  cat "$LOG_FILE"
  exit 1
fi

"$VENV_PYTHON" - <<'PY'
import json
import pathlib
import re
import sys
import urllib.request

base_url = "http://127.0.0.1:8001"
with urllib.request.urlopen(f"{base_url}/openapi.json", timeout=10) as response:
    schema = json.load(response)

openapi_paths = sorted(schema.get("paths", {}).keys())
doc_path = pathlib.Path("docs/api/endpoints.md")
lines = doc_path.read_text().splitlines()

doc_paths = set()
for line in lines:
    if "|" not in line or line.startswith("| Method") or line.startswith("| ------") or line.startswith("| TBD"):
        continue
    match = re.match(r"\|\s*([A-Z]+)\s*\|\s*([^|]+?)\s*\|", line)
    if match:
        doc_paths.add(match.group(2).strip())

missing = sorted(set(openapi_paths) - doc_paths)
extra = sorted(doc_paths - set(openapi_paths))

if missing or extra:
    print("FAIL: OpenAPI paths do not match docs/api/endpoints.md")
    if missing:
        print("Missing from docs:", ", ".join(missing))
    if extra:
        print("Extra paths in docs:", ", ".join(extra))
    raise SystemExit(1)

print("PASS: OpenAPI paths match docs/api/endpoints.md")
print("Paths:", ", ".join(openapi_paths))
PY
