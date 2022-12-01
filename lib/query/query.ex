defmodule SurrealEx.Query do

  # Gives a filter´s list functions than will let us validate the args before prepare to query.
  @callback filters(arg :: any) :: [(any() -> {:ok, nil} | {:error, bitstring()})]
  @callback before(arg :: any) :: {:ok, any()} | {:error, any()}
  @callback query(arg :: any) :: String.t()
  @callback ok(response :: any) :: any()
  @callback error(response :: any) :: any()
  @optional_callbacks filters: 1, before: 1, ok: 1, error: 1

  defmacro __using__(opts) do
    conn_module = Keyword.get(opts, :conn)

    quote bind_quoted: [conn_module: conn_module]
    do

      alias SurrealEx.ArgsChecker

      def run(args) do
        SurrealEx.Query.QueryFlowRunner.run(__MODULE__, unquote(conn_module), args)
      end

    end
  end

end
