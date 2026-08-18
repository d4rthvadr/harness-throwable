# Verification checks

Run these from the repository root before considering a change complete:

```bash
./scripts/check-health.sh
./scripts/check-schema.sh
```

The health script starts the FastAPI app, curls the key routes, and reports PASS/FAIL for each endpoint. The schema script fetches the generated OpenAPI document and verifies the documented endpoint list in `docs/api/endpoints.md` matches the actual API paths.
