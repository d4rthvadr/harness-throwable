from sqlmodel import Session, select

from app.models.book import Book


class BookService:
    @staticmethod
    def create_book(
        session: Session, title: str, author: str, year: int, isbn: str
    ) -> Book:
        book = Book(title=title, author=author, year=year, isbn=isbn)
        session.add(book)
        session.commit()
        session.refresh(book)
        return book

    @staticmethod
    def list_books(session: Session) -> list[Book]:
        return list(session.exec(select(Book)).all())
