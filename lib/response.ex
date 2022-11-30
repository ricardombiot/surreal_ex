defmodule SurrealEx.Response do
  defstruct time: "",
            status: "",
            result: [],
            detail: ""


  def new(json_res) do
    %SurrealEx.Response{
      time: json_res["time"],
      status: json_res["status"],
      result: field_result(json_res["result"]),
      detail: json_res["detail"],
    }
  end

  # Design decision cast maps to dot syntax ¿?
  def to_dot_syntax(list_response) when is_list(list_response) do
    list_response
    |> Enum.map(&to_dot_syntax/1)
  end
  def to_dot_syntax(response = %SurrealEx.Response{}) do
    result = UtilsJsonParser.map_strkeys_to_atomkeys(response.result)
    Map.put(response, :result, result)
  end

  defp field_result(result) when is_list(result) do
    case Enum.count(result) do
      1 -> List.first(result)
      _ -> result
    end
  end
  defp field_result(nil), do: []
  defp field_result(result), do: result

  def build_all(raw_body) do
    Jason.decode!(raw_body)
    |> from_json_build_all_responses()
  end

  defp from_json_build_all_responses(json) when is_list(json) do
    responses = Enum.map(json, &new/1)
    {:ok, responses}
  end
  defp from_json_build_all_responses(json) do
    IO.inspect json
    {:error, "Something wrong when we trying cast responses. Report it please."}
  end


  def all_status_ok?(list_responses) when is_list(list_responses) do
    Enum.all?(list_responses, fn res -> res.status == "OK" end)
  end
  def all_status_ok?(response) do
    response.status == "OK"
  end

end
