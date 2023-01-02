defmodule SurrealExTest.AuthFlowTest do
  use ExUnit.Case

  alias SurrealExTest.Conn

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


  defmodule UpdateRoleFlow do
    use SurrealEx.Query,
      conn: SurrealExTest.Conn

    def filters(_args), do: [ ArgsChecker.required(:role), ArgsChecker.required(:user_id) ]

    def before(args) do
      args = Map.put(args,:role, prepare_role(args.role))
      {:ok, args}
    end
    defp prepare_role(role) do
      case role do
        "notverified" -> 0
        "user" -> 10
        "moderator" -> 20
        "admin" -> 30
      end
    end

    def query(args) do
      "UPDATE #{args.user_id} SET role = #{args.role}"
    end

    def ok(response) do
      case response.result do
        [] -> {:error, "not updated"}
        user -> {:ok, user}
      end
    end

    def error(_response) do
      {:error, "not expected case"}
    end

  end


  test "Using Auth.QueryFlow", _state do
    {:ok, token_customer} = Conn.register("customer", "1234", "example@mail.com")
    {:ok, _token_admin} = Conn.register("admin", "1234", "example@mail.com")

    {:ok, token_admin} = Conn.login("admin", "1234")
    {:ok, user} = Conn.get_user_by_token(token_admin)

    args = %{role: "admin", user_id: user.id}
    {:ok, user} = UpdateRoleFlow.run(args, token_admin)
    assert user["role"] == 30

    {:ok, user} = Conn.get_user_by_token(token_admin)
    assert user.user == "admin"
    assert Map.get(user, "pass") == nil
    assert user.email == "example@mail.com"
    assert user.role == 30

    args = %{role: "notverified", user_id: user.id}
    response = UpdateRoleFlow.run(args, token_customer)
    assert response == {:error, "not updated"}

    {:ok, user} = Conn.get_user_by_token(token_admin)
    assert user.user == "admin"
    assert Map.get(user, "pass") == nil
    assert user.email == "example@mail.com"
    assert user.role == 30

  end

end
