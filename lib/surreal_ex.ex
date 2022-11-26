defmodule SurrealEx do
  @moduledoc """
  Documentation for `SurrealEx`.

  Design Notes: It is interesting can pipe actions (even diferente SQLs) and
  can control easily the flow depending if the database answer was sucessfully or not.

    config
    |> sql(..query..)
    |> when_ok_sql(..query..)
    |> when_ok(..callback..)
    |> when_error(..callback..)

  But I dont like this implementation because its a bit dirty had to pipe the config
  with a 3-tuple.

  @TODO: Save the configuration on a config/config.exs files.

  """

  alias SurrealEx.Response

  def sql(config = %SurrealEx.Config{kind: :for_http}, query) do
    SurrealEx.HTTP.sql(config, query)
    |> answer_for_pipe(config)
  end
  def sql(_config , _query) do
    {:error, "Please, review your configuration %SurrealEx.Config{...}."}
  end


  defp answer_for_pipe({:ok, [response]}, config) do
    {:ok, response, config}
  end
  defp answer_for_pipe({:ok, responses}, config) do
    {:ok, responses, config}
  end


  def when_ok({:ok, responses, config}, fn_callback_ok) do
    case Response.all_status_ok?(responses) do
      true -> fn_callback_ok.(responses, config)
      _ -> {:ok, responses, config}
    end
  end
  def when_ok(res,_query), do: res


  def when_error({:error, responses, config}, fn_callback_error) do
    fn_callback_error.(responses, config)
  end
  def when_error({:ok, responses, config}, fn_callback_error) do
    case Response.all_status_ok?(responses) do
      false -> fn_callback_error.(responses, config)
      _ -> {:ok, responses, config}
    end
  end
  def when_error(res,_query), do: res


  def when_ok_sql(res, query) do
    when_ok(res, fn _res, config ->
      sql(config, query)
    end)
  end


end
