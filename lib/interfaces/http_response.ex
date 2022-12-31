defmodule SurrealEx.HTTPResponse do

  alias SurrealEx.Response

  def build({:ok, %HTTPoison.Response{status_code: 200, body: raw_body}}) do
    Response.build_all({:ok,raw_body})
  end
  def build({:ok, %HTTPoison.Response{status_code: 403, body: raw_body}}) do
    Response.build_all({:error,raw_body})
  end
  def build({:error, %HTTPoison.Error{id: nil, reason: :econnrefused}}) do
    {:error, :econnrefused}
  end
  def build(res) do
    IO.inspect res
    {:error, "Something was wrong..."}
  end

end
