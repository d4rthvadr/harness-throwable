.PHONY: help install run test check health schema

PYTHON ?= python3.12
VENV ?= .venv
PYTHON_BIN := $(VENV)/bin/python
UVICORN := $(VENV)/bin/uvicorn
PYTEST := $(VENV)/bin/pytest

help:
	@echo "Available targets:"
	@echo "  make install   - create venv and install requirements"
	@echo "  make run       - start the FastAPI app with uvicorn"
	@echo "  make test      - run the pytest suite"
	@echo "  make check     - run health and schema verification scripts"
	@echo "  make health    - run the app health check"
	@echo "  make schema    - run the OpenAPI schema check"

install:
	@if [ ! -d "$(VENV)" ]; then $(PYTHON) -m venv $(VENV); fi
	@$(PYTHON_BIN) -m pip install --upgrade pip
	@$(PYTHON_BIN) -m pip install -r requirements.txt

run:
	@$(UVICORN) app.main:app --reload

test:
	@$(PYTEST) -q

health:
	@./scripts/check-health.sh

schema:
	@./scripts/check-schema.sh

check: health schema
