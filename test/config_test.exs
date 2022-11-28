defmodule SurrealExTest.ConfigTest do
  use ExUnit.Case

  test "Reading Enviroment Database Configuration" do
    config = SurrealEx.Config.env_reads()
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


end
