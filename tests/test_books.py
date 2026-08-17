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
