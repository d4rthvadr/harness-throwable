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

    @staticmethod
    def get_book(session: Session, book_id: int) -> Book | None:
        return session.get(Book, book_id)

    @staticmethod
    def update_book(
        session: Session,
        book_id: int,
        title: str | None = None,
        author: str | None = None,
        year: int | None = None,
        isbn: str | None = None,
    ) -> Book | None:
        book = session.get(Book, book_id)
        if book is None:
            return None

        update_fields = {
            "title": title,
            "author": author,
            "year": year,
            "isbn": isbn,
        }

        for field_name, value in update_fields.items():
            if value is not None:
                setattr(book, field_name, value)

        session.add(book)
        session.commit()
        session.refresh(book)
        return book

    @staticmethod
    def delete_book(session: Session, book_id: int) -> bool:
        book = session.get(Book, book_id)
        if book is None:
            return False

        session.delete(book)
        session.commit()
        return True
