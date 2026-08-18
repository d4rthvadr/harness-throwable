from fastapi import APIRouter, Depends, HTTPException, status
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


class BookUpdate(BaseModel):
    title: str | None = None
    author: str | None = None
    year: int | None = None
    isbn: str | None = None


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


@router.get("/count")
def get_book_count(session: Session = Depends(get_session)) -> dict[str, int]:
    return {"count": BookService.count_books(session)}


@router.get("/{book_id}", response_model=Book)
def get_book(book_id: int, session: Session = Depends(get_session)) -> Book:
    book = BookService.get_book(session, book_id)
    if book is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Book not found")
    return book


@router.put("/{book_id}", response_model=Book)
def update_book(
    book_id: int, payload: BookUpdate, session: Session = Depends(get_session)
) -> Book:
    book = BookService.update_book(
        session=session,
        book_id=book_id,
                title=payload.title,
        author=payload.author,
        year=payload.year,
        isbn=payload.isbn,
    )
    if book is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Book not found")
    return book


@router.delete("/{book_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_book(book_id: int, session: Session = Depends(get_session)) -> None:
    deleted = BookService.delete_book(session, book_id)
    if not deleted:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Book not found")
