# Bookshelf API

A small FastAPI tutorial project for managing books with SQLModel and SQLite.

## Tech Stack

- Python 3.12
- FastAPI
- SQLModel
- SQLite
- pytest

## Setup

```bash
python3.12 -m venv .venv
source .venv/bin/activate
python -m pip install -r requirements.txt
```

## Run the app

```bash
uvicorn app.main:app --reload
```

## Run tests

```bash
pytest -q
```

## Architecture

Dependency direction is one-way only:

models -> database -> services -> api

Keep models independent, business logic in services, and routes thin.

## Endpoints

- GET /books
- GET /books/{book_id}
- POST /books
- PUT /books/{book_id}
- DELETE /books/{book_id}
