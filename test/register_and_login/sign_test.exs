defmodule SurrealExTest.SignTest do
  use ExUnit.Case

  alias SurrealExTest.Conn
  alias SurrealEx.HTTPAuth

  setup_all do
    Conn.sql("REMOVE TABLE user")
    login_install()


    [config: Conn.config()]
  end

  def login_install() do
    install_query = "---define SCHEMAFULL and PERMISSIONS
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

                    "

    Conn.sql(install_query)
  end

  test "register", state do
    config = state.config
    {:ok, _token} = HTTPAuth.register(config, "admin", "1234", "example@mail.com")

    user_register = %{
      "user" => "admin",
      "pass" => "1234",
      "email" => "example@mail.com"
    }

    response = HTTPAuth.register(config, user_register)
    assert {:error, :authentication_failed} == response
  end


  test "login", state do
    config = state.config
    {:ok, token} = HTTPAuth.login(config, "admin", "1234")

    {:ok, user} = HTTPAuth.get_user_by_token(config, token)
    assert user.email == "example@mail.com"
    assert user.role == 0

    query = "UPDATE #{user.id} SET role = 10"
    {:ok, [response]} = HTTPAuth.sql(config, query, token)
    #IO.inspect response
    user = response.result
    assert user["user"] == "admin"
    assert Map.get(user, "pass") != nil
    assert user["email"] == "example@mail.com"
    assert user["role"] == 10

    {:ok, user} = HTTPAuth.get_user_by_token(config, token)
    assert user.user == "admin"
    # Remove pass atribute.
    assert Map.get(user, "pass") == nil
    assert user.email == "example@mail.com"
    assert user.role == 10
  end

end
