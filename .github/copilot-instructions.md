# Copilot Instructions

## Project Overview

This repository contains a tutorial Bookshelf API built with FastAPI.
Prioritize readability, layered design, and simple testable components.

## Tech Stack

- Python 3.12
- FastAPI
- SQLite via SQLModel
- pytest

## Run Commands

- Create venv: `python3.12 -m venv .venv`
- Activate venv: `source .venv/bin/activate`
- Install deps: `pip install -r requirements.txt`
- Start server: `uvicorn app.main:app --reload`
- Run tests: `pytest -q`

## Verification Scripts

- Run `./scripts/check-health.sh` to start the app, call the key endpoints, and report PASS/FAIL for each route.
- Run `./scripts/check-schema.sh` to confirm the generated OpenAPI paths match the endpoint inventory in `docs/api/endpoints.md`.
- Use `./scripts/check-health.sh && ./scripts/check-schema.sh` before finalizing a change.

## Architecture

Allowed dependency direction only:
models -> database -> services -> api

Implementation constraints:

- Keep models independent of service and API concerns.
- Keep database concerns isolated to database layer modules.
- Keep services as the business-logic boundary.
- Keep API layer thin: validate, delegate, return.
- Never reverse dependencies between layers.

## Forbidden Patterns

- Importing API modules from services, database, or models.
- Placing domain logic in FastAPI endpoint functions.
- Accessing SQLModel sessions directly in route handlers.
- Cross-layer shortcuts that bypass services.
- Writing tests that rely on shared test order.

## Common Mistakes

- Always regression-test existing functionality when modifying service
  layer functions — the Stop hook will catch this, but catching it
  earlier saves iteration cycles
