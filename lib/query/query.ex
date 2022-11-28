defmodule SurrealEx.Query do

  @callback before(arg :: any) :: {:ok, any()} | {:error, any()}
  @callback query(arg :: any) :: String.t()
  @callback ok(response :: any) :: any()
  @callback error(response :: any) :: any()
  @optional_callbacks before: 1, ok: 1, error: 1

  defmacro __using__(opts) do
    conn_module = Keyword.get(opts, :conn)

    quote bind_quoted: [conn_module: conn_module]
    do

      def run(args) do
        SurrealEx.Query.QueryFlowRunner.run(__MODULE__, unquote(conn_module), args)
      end

    end
  end

end
