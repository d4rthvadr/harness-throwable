from sqlmodel import SQLModel, create_engine

from app.models import book  # noqa: F401

DATABASE_URL = "sqlite:///./bookshelf.db"

engine = create_engine(DATABASE_URL, connect_args={"check_same_thread": False})


def init_db() -> None:
    SQLModel.metadata.create_all(engine)
