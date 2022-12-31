defmodule SurrealExTest.Conn do
  use SurrealEx.Conn
end

defmodule SurrealExTest.ConnNotConfig do
  use SurrealEx.Conn
end

ExUnit.configure([seed: 0])
ExUnit.start()
