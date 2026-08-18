# API Endpoints

This page tracks the public HTTP endpoints for the Bookshelf API.

| Method | Path             | Purpose              | Request Body                                                              | Response                       | Status |
| ------ | ---------------- | -------------------- | ------------------------------------------------------------------------- | ------------------------------ | ------ |
| GET    | /                | Root health check    | —                                                                         | `{"message": "Bookshelf API"}` | 200    |
| POST   | /books/          | Create a book        | `{"title": "string", "author": "string", "year": 2024, "isbn": "string"}` | Book record                    | 201    |
| GET    | /books/          | List all books       | —                                                                         | `[{...book}]`                  | 200    |
| GET    | /books/count     | Count all books      | —                                                                         | `{"count": 0}`                 | 200    |
| GET    | /books/{book_id} | Fetch one book by id | —                                                                         | Book record                    | 200    |
| PUT    | /books/{book_id} | Update one book      | partial book fields                                                       | Updated book record            | 200    |
| DELETE | /books/{book_id} | Delete one book      | —                                                                         | Empty response                 | 204    |
