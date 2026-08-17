# Architecture Overview

## Layered Design

The Bookshelf API follows a strict layered architecture to keep code maintainable and easy to test.
Each layer has one clear responsibility and may depend only on layers below it.

Dependency direction:
models -> database -> services -> api

## Layers

### Models

- Define SQLModel entities and shared domain data structures.
- No API, database wiring, or business workflow logic.

### Database

- Configure engine, sessions, and persistence helpers.
- Uses models for schema definitions.
- Does not depend on services or API modules.

### Services

- Implement business workflows and validation rules.
- Coordinate database operations.
- Return domain-focused results to API layer.

### API

- Define FastAPI routes, request/response models, and HTTP behavior.
- Delegate business work to services.
- Avoid embedding domain logic directly in endpoints.

## Why This Matters

- Reduces coupling and circular dependencies.
- Improves test isolation by layer.
- Makes refactoring safer as the project grows.

## Guardrails

- Never reverse dependency direction.
- Keep endpoint handlers thin.
- Keep business rules in services.
- Keep persistence concerns in database layer.
