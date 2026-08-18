# Bookshelf API Agent Guide

## Project Overview

Bookshelf API is a tutorial backend for managing books and related records.
The goal is clean, testable API design with clear architectural boundaries.

## Tech Stack

- Python 3.12
- FastAPI
- SQLite via SQLModel
- pytest

## Run Commands

- Create venv: `python3.12 -m venv .venv`
- Activate venv: `source .venv/bin/activate`
- Install deps: `pip install -r requirements.txt`
- Run API (dev): `uvicorn app.main:app --reload`
- Run tests: `pytest -q`

## Verification Scripts

- Run `./scripts/check-health.sh` to start the app, hit the critical routes, and report PASS/FAIL for each endpoint.
- Run `./scripts/check-schema.sh` to compare the generated OpenAPI paths against the documented routes in `docs/api/endpoints.md`.
- Run both together with `./scripts/check-health.sh && ./scripts/check-schema.sh` before considering a change complete.

## Architecture Rules

Dependency direction is one-way only:
models -> database -> services -> api

Rules:

- `models` define schema and domain entities only.
- `database` manages engine, sessions, and persistence wiring.
- `services` contain business logic and call database-layer utilities.
- `api` defines routes, request/response handling, and calls services.
- Never import from a higher layer into a lower layer.

## Forbidden Patterns

- Circular imports across layers.
- Business logic inside route handlers.
- Raw SQL scattered in API or service files.
- Direct database session creation inside endpoints.
- Shared mutable global state for request data.

## Common Mistakes

- Always regression-test existing functionality when modifying service
  layer functions — the Stop hook will catch this, but catching it
  earlier saves iteration cycles
