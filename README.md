# SurrealEx

Surreal DB Elixir Library.

## Installation

```elixir
def deps do
  [
    {:surreal_ex, "~> 0.1.0-dev"}
  ]
end
```

### Config

Define a connector file for your project:
 
```elixir
defmodule SurrealExTest.Conn do
  use SurrealEx.Conn
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

[(Learn more on our docs.)](https://hexdocs.pm/surreal_ex/quick_crud.html)

## Custom Queries

![custom_query_execution_flow](https://user-images.githubusercontent.com/113306658/205117894-a48c577d-3254-4536-b1b5-7c190eef73c9.jpg)

[(Learn more on our docs.)](https://hexdocs.pm/surreal_ex/custom_queries.html)


## Register & Login

1. You requires prepare your SCOPE on SurrealDB for example: 

```SQL
---define SCHEMAFULL and PERMISSIONS
DEFINE TABLE user SCHEMAFULL
  PERMISSIONS
    FOR select, update WHERE id = $auth.id,
    FOR create, delete NONE;
--- define FIELD's
DEFINE FIELD user ON user TYPE string;
DEFINE FIELD pass ON user TYPE string;
DEFINE FIELD email ON user TYPE string;
DEFINE FIELD role ON user TYPE int;
--- define INDEX's
DEFINE INDEX idx_user ON user COLUMNS user UNIQUE;

-- define SCOPE
DEFINE SCOPE allusers
  -- the JWT session will be valid for 14 days
  SESSION 14d
  -- The optional SIGNUP clause will be run when calling the signup method for this scope
  -- It is designed to create or add a new record to the database.
  -- If set, it needs to return a record or a record id
  -- The variables can be passed in to the signin method
  SIGNUP ( CREATE user SET user = $user, email = $email, role = $role, pass = crypto::argon2::generate($pass))
  -- The optional SIGNIN clause will be run when calling the signin method for this scope
  -- It is designed to check if a record exists in the database.
  -- If set, it needs to return a record or a record id
  -- The variables can be passed in to the signin method
  SIGNIN ( SELECT * FROM user WHERE user = $user AND crypto::argon2::compare(pass, $pass) )
  -- this optional clause will be run when calling the signup method for this scope
```

2. After you will be able to register new users using:

```elixir
{:ok, _token} = Conn.register("admin", "1234", "example@mail.com")
```
Or 
```elixir
user_register = %{
  "user" => "admin",
  "pass" => "1234",
  "email" => "example@mail.com"
  "otherfield1" => ...
  "otherfield2" => ...
}

{:ok,_token} = Conn.register(user_register)
```

3. You can login (and take token) with:

```elixir
{:ok, token} = Conn.login("admin", "1234")
```

4. And restore information user with:

```elixir
{:ok, user} = Conn.get_user_by_token(token)
#assert user.email == "example@mail.com"
```

[(Learn more on our docs.)](https://hexdocs.pm/surreal_ex/register_and_login.html)
