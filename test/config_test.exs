defmodule SurrealExTest.ConfigTest do
  use ExUnit.Case

  alias SurrealExTest.Conn
  alias SurrealExTest.ConnNotConfig

  test "Reading Enviroment Database Configuration" do
    config = Conn.config()

    assert config == %SurrealEx.Config{
      _prepare: %{
        headers: [
          NS: "testns",
          DB: "testdb",
          Authorization: "Basic cm9vdDpyb290",
          Accept: "application/json"
        ]
      },
      db: "testdb",
      kind: :for_http,
      ns: "testns",
      uri: "http://localhost:8000"
    }
  end

  test "When connector havent config define, we will expected info error." do

    try do
      config = ConnNotConfig.config()

      rescue
        e in SurrealEx.Exception ->
          expected_message =  """
                              #######
                              You need define on config/config.exs:

                              ...

                                config :surreal_ex, SurrealExTest.ConnNotConfig,
                                    interface: ...
                                    ...
                              ...
                              #######
                              """

          assert e.message == expected_message
    end
  end


end
