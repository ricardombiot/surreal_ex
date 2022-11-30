defmodule UtilsJsonParser do


  def map_strkeys_to_atomkeys(list_obj) when is_list(list_obj) do
    list_obj |> Enum.map(&UtilsJsonParser.map_strkeys_to_atomkeys/1)
  end
  def map_strkeys_to_atomkeys(map_obj) do
    map_obj
    |> Map.new(fn {k, v} -> {String.to_atom(k), v} end)
  end

end
