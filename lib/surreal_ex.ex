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

  """

  defmacro __using__(_opts) do

    quote do

      alias SurrealEx.Response

      def config() do
        # Design note:
        #   [X] We can have multiple connections.
        #   But what happend when we will needed use for example user tokens.
        #   [ ] Customize config with dynamic values.
        #    |--> Idea: If each user is on a pid, we can use Process.get(:config, config())
        #
        #
        env_config = Application.get_env(:surreal_ex, __MODULE__)

        case SurrealEx.Config.env_reads(env_config) do
          nil -> SurrealEx.Exception.exception_config_file_should_be_edited(__MODULE__)
          config -> config
        end
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
