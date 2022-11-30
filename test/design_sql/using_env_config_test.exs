defmodule SurrealExTest.DesignSQLSintax.UsingEnvConfigTest do
  use ExUnit.Case

  alias SurrealExTest.Conn
  setup do
    Conn.sql("REMOVE TABLE team")
    |> Conn.when_ok_sql("REMOVE TABLE player")

    :ok
  end


  test "Creating twice the same example record and we expect catch the error", _state do
    query = "CREATE team:valenciacf SET fullname = 'Valencia Club de Fútbol, S.A.D.', shortname = 'Valencia', founded = 1919, league = 'La Liga';"

    # How the list of responses will only have one element, we catch and return it.
    # Why? -> Avoid this syntax: {:ok, [response]} = Conn.sql(query)
    {:ok, response} = Conn.sql(query)
    assert response.status == "OK"
    assert response.detail == nil

    # How the list of results will only have one element, we catch and return it.
    # Why? -> This will allow us work easily with the result object.
    assert !is_list(response.result)

    assert response.result["id"] == "team:valenciacf"
    assert response.result["fullname"] == "Valencia Club de Fútbol, S.A.D."
    assert response.result["shortname"] == "Valencia"
    assert response.result["founded"] == 1919
    assert response.result["league"] == "La Liga"

    {:ok, response} = Conn.sql(query)
    assert response.status == "ERR"
    assert response.detail == "Database record `team:valenciacf` already exists"

  end


  test "Creating two example records and we expect can find them.", _state do
    query = """
      CREATE player:Messi SET fullname = 'Lionel Andrés Messi', shortname = 'Messi', nationality = 'Argentine';
      CREATE player:CR7 SET fullname = 'Cristiano Ronaldo', shortname = 'CR7', nationality = 'Portuguese', age = 37;
    """

    {:ok, list_responses} = Conn.sql(query)
    assert SurrealEx.Response.all_status_ok?(list_responses)

    {:ok, response} = Conn.sql("SELECT * FROM player ORDER BY age DESC")
    response = SurrealEx.Response.to_dot_syntax(response)
    [response_cr7, response_messi] = response.result

    assert response_messi.id == "player:Messi"
    assert response_messi.fullname == "Lionel Andrés Messi"
    assert response_messi.shortname == "Messi"
    assert response_messi.nationality == "Argentine"
    # I dont like that with .dot sintax we can have errors
    #   - if we trust that obj always have all the fields... mmm...
    # Example:
    #  assert response_messi.age == nil <-- throws error
    #
    assert response_messi[:age] == nil

    assert response_cr7.id == "player:CR7"
    assert response_cr7.fullname == "Cristiano Ronaldo"
    assert response_cr7.shortname == "CR7"
    assert response_cr7.nationality == "Portuguese"
    assert response_cr7.age == 37

  end


end
