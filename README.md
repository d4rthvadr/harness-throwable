# Bookshelf API as an AI-Assisted Development Harness

This repository is deliberately not a production books app or a side project for shipping a standalone product. It is a throwaway learning harness designed to exercise a repeatable development loop for AI-assisted coding: verify behavior, diagnose failures, patch the code, run tests, and confirm the fix without drifting into guesswork.

The goal is to create a small but realistic codebase that teaches how to work with:

- layered application design
- FastAPI + SQLModel + SQLite
- testing and regression safety
- OpenAPI/schema verification
- automated validation scripts
- AI-assisted task loops in a constrained, inspectable workflow

This is a learning experience focused on building a reliable workflow for code harnesses, not another bookshelf side project.

## Why this repo exists

This project acts as a sandbox for exploring how AI can support software work in a disciplined way:

- inspect a failing behavior
- read the relevant code and tests
- identify the root cause
- patch the minimal fix
- validate with real commands
- keep the architecture honest and understandable

The business logic is intentionally simple so the focus stays on the development process, not on domain complexity.

## Tech Stack

- Python 3.12
- FastAPI
- SQLModel
- SQLite
- pytest

## Quickstart

```bash
python3.12 -m venv .venv
source .venv/bin/activate
python -m pip install -r requirements.txt
```

### Run the API

```bash
uvicorn app.main:app --reload
```

Then visit:

- http://127.0.0.1:8000/
- http://127.0.0.1:8000/docs

### Run the test suite

```bash
pytest -q
```

### Common commands via Make

```bash
make install
make run
make test
make check
```

The `make check` target runs both verification scripts:

```bash
./scripts/check-health.sh
./scripts/check-schema.sh
```

## Verification workflow

Before considering a change complete, run:

```bash
./scripts/check-health.sh && ./scripts/check-schema.sh
```

These checks confirm the app responds correctly and that the generated OpenAPI paths match the documented endpoint inventory in `docs/api/endpoints.md`.

## Architecture

Dependency direction is one-way only:

models -> database -> services -> api

This keeps the codebase easy to reason about while the harness is being used to test AI-assisted development patterns.

## API endpoints

- GET /
- GET /books/
- GET /books/count
- GET /books/{book_id}
- POST /books/
- PUT /books/{book_id}
- DELETE /books/{book_id}

## Learning intent

This repo is best understood as a code harness for learning how to validate, fix, and test code inside a task loop. It is intentionally lightweight, intentionally inspectable, and intentionally useful as a training ground for disciplined AI-assisted development.
