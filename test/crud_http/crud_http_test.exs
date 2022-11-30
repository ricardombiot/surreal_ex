defmodule SurrealExTest.CRUDHttp.MethodsTest do
  use ExUnit.Case

  alias SurrealExTest.Conn

  setup do
    Conn.sql("REMOVE TABLE book")

    [config: Conn.config()]
  end

  test "Creating item with autogen_id & custom id", state do
    table = "book"
    favorite_book = %{
      isbn: "0-7167-1045-5",
      title: "Computers and Intractability: A Guide to the Theory of NP-Completeness",
      author: "Michael R. Garey and David S. Johnson",
      publication_date:	1979
    }

    assert SurrealEx.HTTP.get(state.config, table, favorite_book.isbn) == {:not_found, nil}

    favorite_book_json = Jason.encode!(favorite_book)
    {:create, autogen_id} =  SurrealEx.HTTP.create(state.config, table, favorite_book_json)

    assert autogen_id != favorite_book.isbn
    "book:" <> autogen_id = autogen_id

    {:found, book} = SurrealEx.HTTP.get(state.config, table, autogen_id)

    assert book.isbn == favorite_book.isbn
    assert book.title == favorite_book.title
    assert book.author == favorite_book.author
    assert book.publication_date == favorite_book.publication_date

    idkey = "0-7167-1045-5"
    {:create_or_update, book} = SurrealEx.HTTP.put(state.config, table, idkey, favorite_book_json)

    assert book.id == "book:⟨0-7167-1045-5⟩"
    assert book.isbn == favorite_book.isbn
    assert book.title == favorite_book.title
    assert book.author == favorite_book.author
    assert book.publication_date == favorite_book.publication_date




  end

  test "Create & Read & Update & Delete", state do
    table = "book"
    favorite_book = %{
      isbn: "9780511804090",
      title: "Computational Complexity: A Modern Approach",
      author: "Sanjeev Arora and Boaz Barak",
      publication_date:	2009
    }

    favorite_book_json = Jason.encode!(favorite_book)
    {:not_found, _} = SurrealEx.HTTP.get(state.config, table, favorite_book.isbn)
    {:create_or_update, book} = SurrealEx.HTTP.put(state.config, table, favorite_book.isbn, favorite_book_json)

    assert book[:keywords] == nil

    book_keywords_field_json = Jason.encode!(%{keywords: ["complexity", "NP-hard", "NP-complete"]})
    {:create_or_update, book} = SurrealEx.HTTP.update(state.config, table, favorite_book.isbn, book_keywords_field_json)
    assert book[:keywords] != nil

    {:found, book} = SurrealEx.HTTP.get(state.config, table, favorite_book.isbn)

    assert book.id == "book:9780511804090"
    assert book.isbn == favorite_book.isbn
    assert book.title == favorite_book.title
    assert book.author == favorite_book.author
    assert book.publication_date == favorite_book.publication_date
    assert book.keywords == ["complexity", "NP-hard", "NP-complete"]

    {:delete, nil} = SurrealEx.HTTP.delete(state.config, table, favorite_book.isbn)

  end

end
