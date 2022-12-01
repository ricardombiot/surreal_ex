# Quick CRUD 

We can define quickly a CRUD for a table using `SurrealEx.HTTP.Table`. 

The configuration requires the following arguments:
- conn: a SurrealEx connector.
- table: CRUD Table 


## Configuration example

```
defmodule SurrealExTest.CRUDHttp.TableTest do
  use ExUnit.Case

  defmodule Conn do
    use SurrealEx
  end

  defmodule TableBook do
    use SurrealEx.HTTP.Table,
      conn: SurrealExTest.CRUDHttp.TableTest.Conn,
      table: "book"
  end

```

## Usage example

```
  test "Creating item with autogen_id & custom id", _state do
    favorite_book = %{
      isbn: "0-7167-1045-5",
      title: "Computers and Intractability: A Guide to the Theory of NP-Completeness",
      author: "Michael R. Garey and David S. Johnson",
      publication_date:	1979
    }

    assert TableBook.get(favorite_book.isbn) == {:not_found, nil}

    {:create, autogen_id} = TableBook.create(favorite_book)

    assert autogen_id != favorite_book.isbn
    "book:" <> autogen_id = autogen_id

    {:found, book} = TableBook.get(autogen_id)

    assert book.isbn == favorite_book.isbn
    assert book.title == favorite_book.title
    assert book.author == favorite_book.author
    assert book.publication_date == favorite_book.publication_date

    idkey = "0-7167-1045-5"
    {:create_or_update, book} = TableBook.put(idkey, favorite_book)

    assert book.id == "book:⟨0-7167-1045-5⟩"
    assert book.isbn == favorite_book.isbn
    assert book.title == favorite_book.title
    assert book.author == favorite_book.author
    assert book.publication_date == favorite_book.publication_date

  end

```
  test "Create & Read & Update & Delete", _state do
    favorite_book = %{
      isbn: "9780511804090",
      title: "Computational Complexity: A Modern Approach",
      author: "Sanjeev Arora and Boaz Barak",
      publication_date:	2009
    }

    {:not_found, _} = TableBook.get(favorite_book.isbn)
    {:create_or_update, book} = TableBook.put(favorite_book.isbn, favorite_book)

    assert book[:keywords] == nil

    book_keywords_field_json = %{keywords: ["complexity", "NP-hard", "NP-complete"]}
    {:create_or_update, book} = TableBook.update(favorite_book.isbn, book_keywords_field_json)
    assert book[:keywords] != nil

    {:found, book} = TableBook.get(favorite_book.isbn)

    assert book.id == "book:9780511804090"
    assert book.isbn == favorite_book.isbn
    assert book.title == favorite_book.title
    assert book.author == favorite_book.author
    assert book.publication_date == favorite_book.publication_date
    assert book.keywords == ["complexity", "NP-hard", "NP-complete"]

    {:delete, nil} = TableBook.delete(favorite_book.isbn)

  end
```