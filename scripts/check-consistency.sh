#!/usr/bin/env bash
set -u

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

PYTHON_BIN="${ROOT_DIR}/.venv/bin/python"

if [[ ! -x "$PYTHON_BIN" ]]; then
  echo "FAIL: Python venv not found at ${PYTHON_BIN}"
  exit 1
fi

"$PYTHON_BIN" - <<'PY'
import pathlib
import re
import sys

root = pathlib.Path('.')

# 1) Compare router paths in code vs docs
app_dir = root / 'app'
code_paths = set()
for py_file in sorted(app_dir.rglob('*.py')):
    text = py_file.read_text()
    for match in re.finditer(r'@app\.(get|post|put|delete)\("([^"]+)"', text):
        code_paths.add(match.group(2))

    router_prefix = None
    router_match = re.search(r'APIRouter\(prefix="([^"]+)"', text)
    if router_match:
        router_prefix = router_match.group(1)

    for match in re.finditer(r'@router\.(get|post|put|delete)\("([^"]+)"', text):
        route_path = match.group(2)
        if router_prefix:
            code_paths.add(router_prefix.rstrip('/') + '/' + route_path.lstrip('/'))
        else:
            code_paths.add(route_path)

# Normalize routes for comparison
normalized_code = {p.rstrip('/') if p != '/' else '/' for p in code_paths}

doc_path = root / 'docs' / 'api' / 'endpoints.md'
text = doc_path.read_text()

doc_paths = set()
for line in text.splitlines():
    if '|' not in line or line.startswith('| Method') or line.startswith('| ------'):
        continue
    match = re.match(r'\|\s*[A-Z]+\s*\|\s*([^|]+?)\s*\|', line)
    if match:
        raw_path = match.group(1).strip()
        if raw_path in {'TBD', '---'}:
            continue
        doc_paths.add(raw_path)

normalized_docs = {p.rstrip('/') if p != '/' else '/' for p in doc_paths}
missing_from_docs = sorted(normalized_code - normalized_docs)
extra_in_docs = sorted(normalized_docs - normalized_code)
if missing_from_docs or extra_in_docs:
    print('FAIL: route inventory drift detected')
    if missing_from_docs:
        print('Missing from docs:', ', '.join(missing_from_docs))
    if extra_in_docs:
        print('Extra in docs:', ', '.join(extra_in_docs))
    raise SystemExit(1)
print('PASS: routes in code match docs/api/endpoints.md')

# 2) Confirm the project test command is documented and present in the repo
readme = (root / 'README.md').read_text()
makefile = (root / 'Makefile').read_text()
if 'pytest -q' not in readme and 'pytest -q' not in makefile:
    print('FAIL: test command not documented in README or Makefile')
    raise SystemExit(1)
print('PASS: pytest -q is documented as the test command')

# 3) Scan for TODO/FIXME/HACK markers in real source/config files, excluding
# docs and the checker itself so the script reports actual drift rather than
# documentation language or its own regex pattern.
ignore_dirs = {'.git', '.venv', '.pytest_cache', '__pycache__', '.mypy_cache'}
results = []
for path in sorted(root.rglob('*')):
    if not path.is_file():
        continue
    if any(part in ignore_dirs for part in path.parts):
        continue
    if path.name == 'check-consistency.sh':
        continue
    if path.suffix.lower() not in {'.py', '.sh', '.yml', '.yaml', '.toml'}:
        continue
    try:
        text = path.read_text(encoding='utf-8')
    except Exception:
        continue
    if re.search(r'TODO|FIXME|XXX|HACK', text, flags=re.IGNORECASE):
        results.append(str(path))

if results:
    print('FAIL: TODO/FIXME/HACK markers found:')
    for result in results:
        print(' -', result)
    raise SystemExit(1)
print('PASS: no TODO/FIXME/XXX/HACK markers found in source/config files')
PY
