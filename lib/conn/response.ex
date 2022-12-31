defmodule SurrealEx.Response do
  defstruct time: "",
            status: "",
            result: [],
            detail: ""


  @doc """
  SurrealEx.Response structure constructor cast the SurrealDB´S JSON responses.

  ## Example:

      iex> json_res = %{ "time" => "775.74µs",
      ...>  "status" => "OK",
      ...>  "detail" => "",
      ...>  "result" => [%{
      ...>    "id" => "person:bob",
      ...>    "name" => "bob"
      ...>  }]
      ...>}
      iex> response = SurrealEx.Response.new(json_res)
      iex> response.time
      "775.74µs"
      iex> response.status
      "OK"
      iex> response.detail
      ""
      iex> response.result
      %{"id" => "person:bob","name" => "bob"}

  """
  def new(json_res) do
    %SurrealEx.Response{
      time: json_res["time"],
      status: json_res["status"],
      result: field_result(json_res["result"]),
      detail: json_res["detail"],
    }
  end

  @doc """
    Using `to_dot_syntax` we will can work using dot syntax with result field.

    IMPORTANT: Remember that if you try access to field with dot and this field isnt exist will throws KeyError (See following example...)

  ## Example:

      iex> json_res = %{ "time" => "127.74µs",
      ...>  "status" => "OK",
      ...>  "detail" => "",
      ...>  "result" => [
      ...>    %{ "id" => "city:esvalencia", "name" => "Valencia",  "population" => 791_413 },
      ...>    %{ "id" => "city:esmadrid", "name" => "Madrid", "area" => 604.45 },
      ...>    %{ "id" => "city:esbarcelona", "name" => "Barcelona" }
      ...>  ]}
      iex> response = SurrealEx.Response.new(json_res)
      ...>  |> SurrealEx.Response.to_dot_syntax()
      iex> [valencia, madrid, barcelona] = response.result
      iex> valencia.population
      791_413
      iex> madrid.area
      604.45
      iex> barcelona.area
      ** (KeyError) key :area not found in: %{id: "city:esbarcelona", name: "Barcelona"}


  """
  def to_dot_syntax(list_response) when is_list(list_response) do
    list_response
    |> Enum.map(&to_dot_syntax/1)
  end
  def to_dot_syntax(response = %SurrealEx.Response{}) do
    result = SurrealEx.UtilsJsonParser.map_strkeys_to_atomkeys(response.result)
    Map.put(response, :result, result)
  end

  defp field_result([result]), do: result
  defp field_result(nil), do: []
  defp field_result(result), do: result


  @doc """
  From raw Surreal DB response (that can gives us many responses) we can build the responses list [%SurrealEx.Response{...}] using `build_all(raw_body)`.


  ## Example:

      iex> raw_body = "[{\\"time\\":\\"77.182µs\\",\\"status\\":\\"ERR\\",\\"detail\\":\\"Database record `team:valenciacf` already exists\\"}]"
      iex> {:ok, response} = SurrealEx.Response.build_all({:ok,raw_body})
      iex> response
      [
        %SurrealEx.Response{
          time: "77.182µs",
          status: "ERR",
          detail: "Database record `team:valenciacf` already exists",
          result: []
        }
      ]

  """
  def build_all({:ok,raw_body}) do
    Jason.decode!(raw_body)
    |> from_json_build_all_responses()
  end
  def build_all({:error,raw_body}) do
    error_message = Jason.decode!(raw_body)
   # IO.inspect error_message
    case {error_message["code"], error_message["details"]} do
      {403, "Authentication failed"} -> {:error, :authentication_failed}
      {403, _} -> {:error, :forbidden}
      _ -> {:error, error_message}
    end
  end

  defp from_json_build_all_responses(json) when is_list(json) do
    responses = Enum.map(json, &new/1)
    {:ok, responses}
  end
  defp from_json_build_all_responses(%{"code" => 200, "details" => "Authentication succeeded", "token" => token}) do
    {:ok, token}
  end
  defp from_json_build_all_responses(json) do
    IO.inspect json
    {:error, "Something wrong when we trying cast responses. Report it please."}
  end

  @doc """
  `all_status_ok?` reads all responses status searching that all will be "OK".

  ## Example:

      iex> raw_body = "[{\\"time\\":\\"77.182µs\\",\\"status\\":\\"OK\\",\\"detail\\":\\"\\"}, {\\"time\\":\\"77.182µs\\",\\"status\\":\\"OK\\",\\"detail\\":\\"\\"}]"
      iex> {:ok, response} = SurrealEx.Response.build_all({:ok,raw_body})
      iex> SurrealEx.Response.all_status_ok?(response)
      true

      iex> raw_body = "[{\\"time\\":\\"77.182µs\\",\\"status\\":\\"ERR\\",\\"detail\\":\\"Database record `team:valenciacf` already exists\\"}, {\\"time\\":\\"77.182µs\\",\\"status\\":\\"OK\\",\\"detail\\":\\"\\"}]"
      iex> {:ok, response} = SurrealEx.Response.build_all({:ok,raw_body})
      iex> SurrealEx.Response.all_status_ok?(response)
      false

  """
  def all_status_ok?(list_responses) when is_list(list_responses) do
    Enum.all?(list_responses, &all_status_ok?/1)
  end
  def all_status_ok?(response) do
    response.status == "OK"
  end

end
