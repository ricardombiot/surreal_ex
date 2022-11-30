defmodule UtilsJsonParser do


  def map_strkeys_to_atomkeys(map_obj) do
    map_obj
    |> Map.new(fn {k, v} -> {String.to_atom(k), v} end)
  end

end
