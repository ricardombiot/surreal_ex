defmodule SurrealExTest.DesignQueries.ExampleFlow do

  def before(args) do
    # Logical checks

    IO.puts "before"
    {:ok, args}
  end

  def query(args) do
    "SELECT * FROM house WHERE price <= #{args.price_max}"
  end

  def ok(response) do

    IO.inspect response
  end

  def error(response) do
    IO.inspect response
  end

end
