import Config

config :surreal_ex, SurrealExTest.Conn,
  interface: :http,
  uri: "http://localhost:8000",
  ns: "testns",
  db: "testdb",
  user: "root",
  pass: "root"


config :surreal_ex, SurrealExTest.QueryTest.Conn,
  interface: :http,
  uri: "http://localhost:8000",
  ns: "testns",
  db: "testdb",
  user: "root",
  pass: "root"

config :surreal_ex, SurrealExTest.QueryFiltersTest.Conn,
  interface: :http,
  uri: "http://localhost:8000",
  ns: "testns",
  db: "testdb",
  user: "root",
  pass: "root"

config :surreal_ex, SurrealExTest.CRUDHttp.TableTest.Conn,
  interface: :http,
  uri: "http://localhost:8000",
  ns: "testns",
  db: "testdb",
  user: "root",
  pass: "root"
