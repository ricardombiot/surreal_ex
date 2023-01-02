defmodule SurrealEx.Query.QueryFlowRunner do

  def run(module, conn_module, args) do
    optional_filters(module, args)
    |> flow_optional_before(module)
    |> flow_query(module, conn_module)
  end
  def run(module, conn_module, args, token) do
    optional_filters(module, args)
    |> flow_optional_before(module)
    |> flow_query(module, conn_module, token)
  end

  defp flow_optional_before({:ok, args}, module), do: optional_before(module, args)
  defp flow_optional_before(err, _module), do: err

  defp flow_query({:ok, query_args}, module, conn_module) do
    prepare_query(module, query_args)
    |> exe_query(conn_module)
    |> optional_after(module)
  end
  defp flow_query({:ok, query_args}, module, conn_module, token) do
    prepare_query(module, query_args)
    |> exe_query(conn_module, token)
    |> optional_after(module)
  end
  defp flow_query(err, _module, _conn_module), do: err
  defp flow_query(err, _module, _conn_module, _token), do: err


  defp optional_filters(module, args) do
    if Kernel.function_exported?(module, :filters, 1) do
      filters = apply(module, :filters, [args])
      SurrealEx.ArgsChecker.apply(args, filters)
    else
      {:ok, args}
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
  defp exe_query(query, conn_module, token) when is_bitstring(query) and is_bitstring(token) do
    apply(conn_module, :sql, [query, token])
  end
  defp exe_query(_query, _conn_module) do
    SurrealEx.Exception.query_should_be_string()
  end
  defp exe_query(_query, _conn_module, _token) do
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
