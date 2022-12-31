defmodule SurrealExTest.ConfigTest do
  use ExUnit.Case

  alias SurrealExTest.Conn
  alias SurrealEx.HTTPResponse


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
                    DEFINE FIELD role ON user TYPE string;
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

    url = "#{config.uri}/signup"
    headers = config._prepare.headers
    options = []

    query = %{
      "ns" => config.ns ,
      "db" => config.db ,
      "sc" => "allusers",
      "user" => "admin",
      "pass" => "1234",
      "email" => "example@mail.com"
    }
    query_txt = Jason.encode!(query)

    response = HTTPoison.post(url, query_txt , headers, options)
      |> HTTPResponse.build()

    IO.inspect response

    response = HTTPoison.post(url, query_txt , headers, options)
    |> HTTPResponse.build()

    #IO.inspect response
    assert {:error, :authentication_failed} == response

  end

  test "login", state do
    IO.puts "Login"
    config = state.config

    url = "#{config.uri}/signin"
    headers = config._prepare.headers
      |> Keyword.delete(:Authorization)
    options = []

    query = %{
      "ns" => config.ns ,
      "db" => config.db ,
      "sc" => "allusers",
      "user" => "admin",
      "pass" => "1234",
    }
    query_txt = Jason.encode!(query)

    response = HTTPoison.post(url, query_txt , headers, options)
      |> HTTPResponse.build()
    {:ok, token} = response


    url = "#{config.uri}/sql"
    headers = config._prepare.headers
      |> Keyword.put(:Authorization, "Bearer " <> token)
    options = []

    query = "select * from user where id = $auth.id"
    response = HTTPoison.post(url, query , headers, options)
    |> HTTPResponse.build()

    IO.inspect response
  end


end
