# Bookshelf API

A small FastAPI tutorial project for managing books with SQLModel and SQLite.

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

## Verification

Before considering a change complete, run:

```bash
./scripts/check-health.sh && ./scripts/check-schema.sh
```

These checks confirm the app is healthy and that the generated OpenAPI paths match the documented endpoint inventory in `docs/api/endpoints.md`.

## Architecture

Dependency direction is one-way only:

models -> database -> services -> api

Keep models independent, business logic in services, and routes thin.

## API endpoints

- GET /
- GET /books/
- GET /books/count
- GET /books/{book_id}
- POST /books/
- PUT /books/{book_id}
- DELETE /books/{book_id}
