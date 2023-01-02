# Register and Login 

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

## Using Connector

2. Define a connector file for your project:
 
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

3. After you will be able to register new users using:

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

4. You can login (and take token) with:

```elixir
{:ok, token} = Conn.login("admin", "1234")
```

5. And restore information user with:

```elixir
{:ok, user} = Conn.get_user_by_token(token)
#assert user.email == "example@mail.com"
```



## Using SurrealEx.HTTPAuth


2. After you will be able to register new users using:

```elixir
{:ok, _token} = SurrealEx.HTTPAuth.register(config, "admin", "1234", "example@mail.com")
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

{:ok,_token} = SurrealEx.HTTPAuth.register(config, user_register)
```

3. You can login (and take token) with:

```elixir
{:ok, token} = SurrealEx.HTTPAuth.login(config, "admin", "1234")
```

4. And restore information user with:

```elixir
{:ok, user} = HTTPAuth.get_user_by_token(config, token)
#assert user.email == "example@mail.com"
```