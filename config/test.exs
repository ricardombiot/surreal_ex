import Config

config :surreal_ex, SurrealExTest.Conn,
  interface: :http,
  uri: "http://localhost:8000",
  ns: "testns",
  db: "testdb",
  user: "root",
  pass: "root"
