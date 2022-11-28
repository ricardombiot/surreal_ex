defmodule SurrealEx.Query.QueryFlowRunner do

  def run(module, conn_module, args) do
    case optional_before(module, args) do
      {:ok, query_args} ->
        prepare_query(module, query_args)
        |> exe_query(conn_module)
        |> optional_after(module)
      output -> output
    end
  end

  defp optional_before(module, args) do
    if Kernel.function_exported?(module, :before, 1) do
      apply(module, :before, [args])
    else
      {:ok, args}
    end
  end

  defp prepare_query(module, query_args) do
    apply(module, :query, [query_args])
  end

  defp exe_query(query, conn_module) when is_bitstring(query) do
    apply(conn_module, :sql, [query])
  end
  defp exe_query(_query, _conn_module) do
    SurrealEx.Exception.query_should_be_string()
  end

  defp optional_after({:ok, response}, module) do
    if Kernel.function_exported?(module, :ok, 1) do
      apply(module, :ok, [response])
    else
      {:ok, response}
    end
  end
  defp optional_after({:error, response}, module) do
    if Kernel.function_exported?(module, :error, 1) do
      apply(module, :error, [response])
    else
      {:error, response}
    end
  end



end
