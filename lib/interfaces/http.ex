defmodule SurrealEx.HTTP do

  alias SurrealEx.HTTPResponse

  def sql(config, query) do
    url = "#{config.uri}/sql"
    headers = config._prepare.headers
    options = []

    HTTPoison.post(url, query, headers, options)
    |> HTTPResponse.build()
  end

  def get(config, table, id) do
    url = "#{config.uri}/key/#{table}/#{id}"
    headers = config._prepare.headers
    options = []

    HTTPoison.get(url, headers, options)
    |> HTTPResponse.build()
    |> response_get()
  end

  defp response_get({:ok, [response]}) do
    cond do
      response.status == "OK" && response.result == [] ->
        {:not_found, nil}
      response.status == "ERR" ->
        {:error, response.detail}
      true ->
        item = response.result
        {:found, item}
    end
  end
  defp response_get(err), do: err

  def create(config, table, body) do
    url = "#{config.uri}/key/#{table}"
    headers = config._prepare.headers
    options = []

    HTTPoison.post(url, body, headers, options)
    |> HTTPResponse.build()
    |> response_create()
  end

  defp response_create({:ok, [response]}) do
    cond do
      response.status == "ERR" ->
        {:error, response.detail}
      true ->
        id = response.result[:id]
        {:create, id}
    end
  end
  defp response_create(err), do: err

  def put(config, table, id, body) do
    url = "#{config.uri}/key/#{table}/#{id}"
    headers = config._prepare.headers
    options = []

    HTTPoison.put(url, body, headers, options)
    |> HTTPResponse.build()
    |> response_put()
  end

  defp response_put({:ok, [response]}) do
    cond do
      response.status == "ERR" ->
        {:error, response.detail}
      true ->
        item = response.result
        {:create_or_update, item}
    end
  end
  defp response_put(err), do: err

  def update(config, table, id, body) do
    url = "#{config.uri}/key/#{table}/#{id}"
    headers = config._prepare.headers
    options = []

    HTTPoison.patch(url, body, headers, options)
    |> HTTPResponse.build()
    |> response_update()
  end

  defp response_update({:ok, [response]}) do
    cond do
      response.status == "ERR" ->
        {:error, response.detail}
      true ->
        item = response.result
        {:create_or_update, item}
    end
  end
  defp response_update(err), do: err

  def delete(config, table, id) do
    url = "#{config.uri}/key/#{table}/#{id}"
    headers = config._prepare.headers
    options = []

    HTTPoison.delete(url, headers, options)
    |> HTTPResponse.build()
    |> response_delete()
  end

  defp response_delete({:ok, [response]}) do
    cond do
      response.status == "ERR" ->
        {:error, response.detail}
      true ->
        {:delete, nil}
    end
  end
  defp response_delete(err), do: err

end
