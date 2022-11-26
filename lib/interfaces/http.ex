defmodule SurrealEx.HTTP do

  alias SurrealEx.HTTPResponse

  def sql(config, query) do
    url = "#{config.uri}/sql"
    headers = config._prepare.headers
    options = []

    HTTPoison.post(url, query, headers, options)
    |> HTTPResponse.build()
  end


end
