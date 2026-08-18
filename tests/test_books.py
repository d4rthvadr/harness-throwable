def test_root_health(client):
    response = client.get("/")

    assert response.status_code == 200
    assert response.json() == {"message": "Bookshelf API"}


def test_create_book(client):
    response = client.post(
        "/books/",
        json={
            "title": "1984",
            "author": "George Orwell",
            "year": 1949,
            "isbn": "9780451524935",
        },
    )

    assert response.status_code == 201
    body = response.json()
    assert body["id"] is not None
    assert body["title"] == "1984"


def test_list_books_returns_created_records(client):
    client.post(
        "/books/",
        json={
            "title": "Dune",
            "author": "Frank Herbert",
            "year": 1965,
            "isbn": "9780441172719",
        },
    )

    response = client.get("/books/")

    assert response.status_code == 200
    books = response.json()
    assert len(books) == 1
    assert books[0]["title"] == "Dune"


def test_get_book_count(client):
    client.post(
        "/books/",
        json={
            "title": "The Hobbit",
            "author": "J.R.R. Tolkien",
            "year": 1937,
            "isbn": "9780547928227",
        },
    )
    client.post(
        "/books/",
        json={
            "title": "Foundation",
            "author": "Isaac Asimov",
            "year": 1951,
            "isbn": "9780553293357",
        },
    )

    response = client.get("/books/count")

    assert response.status_code == 200
    assert response.json() == {"count": 2}


def test_get_book_by_id(client):
    create_response = client.post(
        "/books/",
        json={
            "title": "The Hobbit",
            "author": "J.R.R. Tolkien",
            "year": 1937,
            "isbn": "9780547928227",
        },
    )
    book_id = create_response.json()["id"]

    response = client.get(f"/books/{book_id}")

    assert response.status_code == 200
    book = response.json()
    assert book["id"] == book_id
    assert book["title"] == "The Hobbit"


def test_update_book(client):
    create_response = client.post(
        "/books/",
        json={
            "title": "Old Title",
            "author": "Jane Doe",
            "year": 2001,
            "isbn": "9781111111111",
        },
    )
    book_id = create_response.json()["id"]

    response = client.put(
        f"/books/{book_id}",
        json={
            "title": "New Title",
            "author": "Jane Doe",
            "year": 2002,
            "isbn": "9781111111111",
        },
    )

    assert response.status_code == 200
    body = response.json()
    assert body["id"] == book_id
    assert body["title"] == "New Title"
    assert body["year"] == 2002


def test_delete_book(client):
    create_response = client.post(
        "/books/",
        json={
            "title": "Delete Me",
            "author": "Cleanup Bot",
            "year": 2020,
            "isbn": "9782222222222",
        },
    )
    book_id = create_response.json()["id"]

    delete_response = client.delete(f"/books/{book_id}")
    get_response = client.get(f"/books/{book_id}")

    assert delete_response.status_code == 204
    assert get_response.status_code == 404


def test_get_nonexistent_book_returns_404(client):
    response = client.get("/books/999999")

    assert response.status_code == 404
    assert response.json()["detail"] == "Book not found"
