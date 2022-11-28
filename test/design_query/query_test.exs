defmodule SurrealExTest.QueryTest do
  use ExUnit.Case

  alias SurrealEx.Query.QueryFlowRunner

  defmodule Conn do
    use SurrealEx
  end

  defmodule ExampleFlow do

    def before(args) do
      # Logical checks

      IO.puts "before"
      {:ok, args}
    end

    def query(args) do
      "SELECT * FROM house WHERE price <= #{args.price_max}"
    end

    def ok(response) do

      IO.puts "OK"
      IO.inspect response
    end

    def error(response) do
      IO.inspect response
    end

  end

  test "Checks flow" do
    module = SurrealExTest.QueryTest.ExampleFlow
    conn_module = SurrealExTest.QueryTest.Conn

    args = %{
      price_max: 1000.00
    }
    result = QueryFlowRunner.run(module, conn_module, args)


  end

end
