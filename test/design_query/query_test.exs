defmodule SurrealExTest.QueryTest do
  use ExUnit.Case

  defmodule Conn do
    use SurrealEx
  end

  defmodule ExampleFlow do
    use SurrealEx.Query,
      conn: SurrealExTest.QueryTest.Conn

    def before(args) do
      # Logical checks
      cond do
        args[:price_max] == nil -> {:error, "price_max required"}
        !is_number(args[:price_max]) -> {:error, "price_max should be number"}
        true -> {:ok, args}
      end
    end

    def query(args) do
      "SELECT * FROM car WHERE price <= #{args.price_max}"
    end

    def ok(response) do
      {:ok, response.result}
    end

    def error(_response) do
      {:error, "not expected case"}
    end

  end

  ##########

  setup_all do
    Conn.sql("REMOVE TABLE car")
    |> Conn.when_ok_sql("CREATE car SET name = 'Golf', year = 2006 , desc= 'good state', km = 82903 , price = 14050")
    |> Conn.when_ok_sql("CREATE car SET name = 'Mercedes-Benz', year = 2012 , desc= 'its ok', km = 102903 , price = 7050")
    |> Conn.when_ok_sql("CREATE car SET name = 'Tesla', year = 2022 , desc= 'excelent', km = 100 , price = 53000")

    :ok
  end


  test "We expected that on before function checks args." do
    args = %{}
    {:error, detail} = ExampleFlow.run(args)

    assert detail == "price_max required"

    args = %{
      price_max: "15000.00"
    }
    {:error, detail} = ExampleFlow.run(args)

    assert detail == "price_max should be number"
  end

  test "Simple query testing" do
    args = %{
      price_max: 15000.00
    }
    {:ok, list_cars} = ExampleFlow.run(args)

    assert Enum.map(list_cars, fn car -> car["price"] <= 15000 end)
      |> Enum.all?
  end

end
