defmodule SurrealExTest.QueryFiltersTest do
  use ExUnit.Case

  defmodule Conn do
    use SurrealEx.Conn
  end

  defmodule ExampleFlow do
    use SurrealEx.Query,
      conn: SurrealExTest.QueryFiltersTest.Conn

    def filters(_args) do
      [
        ArgsChecker.required(:price_max),
        ArgsChecker.should_be(:price_max, :float),
        ArgsChecker.greater_than(:price_max, 0.0)
      ]
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

  setup do
    Conn.sql("REMOVE TABLE car")
    |> Conn.when_ok_sql("CREATE car SET name = 'Golf', year = 2006 , desc= 'good state', km = 82903 , price = 14050")
    |> Conn.when_ok_sql("CREATE car SET name = 'Mercedes-Benz', year = 2012 , desc= 'its ok', km = 102903 , price = 7050")
    |> Conn.when_ok_sql("CREATE car SET name = 'Tesla', year = 2022 , desc= 'excelent', km = 100 , price = 53000")

    :ok
  end


  test "We expected that on before function checks args." do
    args = %{}
    {:error, detail} = ExampleFlow.run(args)

    assert detail == [
      "'price_max' is required",
      "'price_max' should be float",
      "'price_max' should be greater than 0.0"
    ]

    args = %{
      price_max: "15000.00"
    }
    {:error, detail} = ExampleFlow.run(args)

    assert detail == [
      "'price_max' should be float",
      "'price_max' should be greater than 0.0"
    ]
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
