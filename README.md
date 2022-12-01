# SurrealEx

Surreal DB Elixir Library.


## Installation

```elixir
def deps do
  [
    {:surreal_ex, "~> 0.1.0"}
  ]
end
```

### Config

Define a connector file for your project:
 
```elixir
defmodule SurrealExTest.Conn do
  use SurrealEx
end
```

Adds on your config file, the session configuration parameters:

```elixir
...
config :surreal_ex, SurrealExTest.Conn,
  interface: :http,
  uri: "http://localhost:8000",
  ns: "testns",
  db: "testdb",
  user: "root",
  pass: "root"
...
```

## SQL Queries

Using your connector you can execute a queries for example:

```elixir
  test "Creating twice the same example record and we expect catch the error", _state do
    query = "CREATE team:valenciacf SET fullname = 'Valencia Club de Fútbol, S.A.D.', shortname = 'Valencia', founded = 1919, league = 'La Liga';"

    {:ok, response} = Conn.sql(query)
    assert response.status == "OK"
    assert response.detail == nil
    assert !is_list(response.result)

    assert response.result["id"] == "team:valenciacf"
    assert response.result["fullname"] == "Valencia Club de Fútbol, S.A.D."
    assert response.result["shortname"] == "Valencia"
    assert response.result["founded"] == 1919
    assert response.result["league"] == "La Liga"

    {:ok, response} = Conn.sql(query)
    assert response.status == "ERR"
    assert response.detail == "Database record `team:valenciacf` already exists"

  end

```

## Quick CRUD

```elixir
  defmodule TableBook do
    use SurrealEx.HTTP.Table,
      conn: SurrealExTest.CRUDHttp.TableTest.Conn,
      table: "book"

      # It will allow you use the following methods:
      #
      # get(id) 
      # create(obj)
      # put(id, obj)
      # update(id, obj)
      # delete(id)

  end
```

(See more on our docs.)

## Custom Queries

![alt text](assets/custom_query_execution_flow.jpg)

(See more on our docs.)