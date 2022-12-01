defmodule SurrealEx.Conn do
  @moduledoc """
  Documentation for `SurrealEx.Conn`.

  Design Notes: It is interesting can pipe actions (even diferente SQLs) and
  can control easily the flow depending if the database answer was sucessfully or not.


    config
    |> sql(..query..)
    |> when_ok_sql(..query..)
    |> when_ok(..callback..)
    |> when_error(..callback..)

  """

  defmacro __using__(_opts) do

    quote do

      alias SurrealEx.Response

      def config() do
        SurrealEx.Config.get_config(__MODULE__)
      end

      def set_config_pid(config) do
        SurrealEx.Config.set_config_pid(config)
      end

      def sql(query) when is_bitstring(query) do
        config()
        |> sql(query)
      end
      def sql(config = %SurrealEx.Config{kind: :for_http}, query) do
        SurrealEx.HTTP.sql(config, query)
        |> if_only_one_response_catchit()
      end
      def sql(_config , _query) do
        {:error, "Please, review your configuration %SurrealEx.Config{...}."}
      end

      defp if_only_one_response_catchit({:ok, [response]}) do
        {:ok, response}
      end
      defp if_only_one_response_catchit(res), do: res


      def when_ok({:ok, responses}, fn_callback_ok) do
        case Response.all_status_ok?(responses) do
          true -> fn_callback_ok.(responses)
          _ -> {:ok, responses}
        end
      end
      def when_ok(res,_query), do: res


      def when_error({:error, responses}, fn_callback_error) do
        fn_callback_error.(responses)
      end
      def when_error({:ok, responses}, fn_callback_error) do
        case Response.all_status_ok?(responses) do
          false -> fn_callback_error.(responses)
          _ -> {:ok, responses}
        end
      end
      def when_error(res,_query), do: res


      def when_ok_sql(res, query) do
        when_ok(res, fn _res ->
          sql(query)
        end)
      end

    end

  end


end
