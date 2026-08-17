from fastapi import FastAPI

from app.api.routes.books import router as books_router
from app.database.engine import init_db

app = FastAPI(title="Bookshelf API")


@app.on_event("startup")
def startup() -> None:
    init_db()


@app.get("/")
def root() -> dict[str, str]:
    return {"message": "Bookshelf API"}


app.include_router(books_router)
