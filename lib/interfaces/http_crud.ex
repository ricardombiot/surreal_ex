defmodule SurrealEx.HTTP.Table do

  defmacro __using__(opts) do
    conn_module = Keyword.get(opts, :conn)
    table = Keyword.get(opts, :table)

    quote bind_quoted: [conn_module: conn_module, table: table]
    do

      defp config() do
        apply(unquote(conn_module), :config, [])
      end

      def get(id) do
        SurrealEx.HTTP.get(config(), unquote(table), id)
      end

      def create(body) do
        body = Jason.encode!(body)
        SurrealEx.HTTP.create(config(), unquote(table), body)
      end

      def put(id, body) do
        body = Jason.encode!(body)
        SurrealEx.HTTP.put(config(), unquote(table), id, body)
      end

      def update(id, body) do
        body = Jason.encode!(body)
        SurrealEx.HTTP.update(config(), unquote(table), id, body)
      end

      def delete(id) do
        SurrealEx.HTTP.delete(config(), unquote(table), id)
      end

    end
  end


end
