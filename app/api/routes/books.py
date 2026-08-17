from fastapi import APIRouter, Depends, status
from pydantic import BaseModel
from sqlmodel import Session

from app.database.session import get_session
from app.models.book import Book
from app.services.book_service import BookService

router = APIRouter(prefix="/books", tags=["books"])


class BookCreate(BaseModel):
    title: str
    author: str
    year: int
    isbn: str


@router.post("/", response_model=Book, status_code=status.HTTP_201_CREATED)
def create_book(payload: BookCreate, session: Session = Depends(get_session)) -> Book:
    return BookService.create_book(
        session=session,
        title=payload.title,
        author=payload.author,
        year=payload.year,
        isbn=payload.isbn,
    )


@router.get("/", response_model=list[Book])
def get_books(session: Session = Depends(get_session)) -> list[Book]:
    return BookService.list_books(session)
