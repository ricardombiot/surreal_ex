defmodule SurrealEx.Config do
  defstruct kind: :none,
            uri: "",
            ns: "",
            db: "",
            _prepare: %{}


  def env_reads(env_config) do
    case env_config[:interface] do
      :http -> for_http(env_config)
      _ -> nil
    end
  end

  def set_config_pid(config) do
    Process.put(:conn_config, config)
  end

  @doc ~S"""
  Prepare connection configuration for HTTP with Basic Authorization

  ## Examples

      iex> config = SurrealEx.Config.for_http("http://localhost:8000","testns","testdb","root","root")
      iex> config.kind
      :for_http
      iex> config.uri
      "http://localhost:8000"
      iex> config.ns
      "testns"
      iex> config.db
      "testdb"


      iex> config = SurrealEx.Config.for_http("http://localhost:8000","testns","testdb","root","root")
      iex> config._prepare
      %{
        headers: [
          "NS": "testns",
          "DB": "testdb",
          "Authorization": "Basic cm9vdDpyb290",
          "Accept": "application/json"
        ]
      }


  """
  def for_http(env_config) do
    for_http(env_config[:uri], env_config[:ns], env_config[:db], env_config[:user], env_config[:pass])
  end
  def for_http(uri, ns, db, user, pass) do
    basic_auth = Base.encode64("#{user}:#{pass}")
    prepare_conn = %{
        headers: [
          "NS": ns,
          "DB": db,
          "Authorization": "Basic #{basic_auth}",
          "Accept": "application/json"
        ]
    }

    %SurrealEx.Config{
      kind: :for_http,
      uri: uri,
      ns: ns,
      db: db,
      _prepare: prepare_conn
    }
  end

end
