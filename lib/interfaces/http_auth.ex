defmodule SurrealEx.HTTPAuth do

  alias SurrealEx.HTTPResponse
  alias SurrealEx.UtilsJsonParser


  def register(config, username, password, email) do
    register(config, username, password, email, 0)
  end
  def register(config, username, password, email, role) do
    user = %{
      "user" => username,
      "pass" => password,
      "email" => email,
      "role" => role
    }

    register(config, user)
  end
  def register(config, user) do
    url = "#{config.uri}/signup"
    headers = config._prepare.headers
    options = []

    json_user_register = user
     |> Map.put("ns", config.ns)
     |> Map.put("db", config.db)
     |> Map.put("sc", "allusers")
     |> Jason.encode!()

    HTTPoison.post(url, json_user_register, headers, options)
    |> HTTPResponse.build()
  end

  def login(config, username, password) do
    url = "#{config.uri}/signin"
    headers = config._prepare.headers
      |> Keyword.delete(:Authorization)
    options = []

    json_user_login = %{
      "ns" => config.ns ,
      "db" => config.db ,
      "sc" => "allusers" ,
      "user" => username ,
      "pass" => password ,
    } |> Jason.encode!()

    HTTPoison.post(url, json_user_login, headers, options)
    |> HTTPResponse.build()
  end

  def get_user_by_token(config, token) do
    query = "select * from user where id = $auth.id"

    case sql(config, query, token) do
      {:ok, [response]} ->
        result = response.result
          |> Map.delete("pass")
          |> UtilsJsonParser.map_strkeys_to_atomkeys()

        {:ok, result}
      _ -> {:error, nil}
    end
  end

  def sql(config, query, token) do
    url = "#{config.uri}/sql"
    headers = config._prepare.headers
      |> Keyword.put(:Authorization, "Bearer " <> token)
    options = []

    HTTPoison.post(url, query , headers, options)
    |> HTTPResponse.build()
  end


end
