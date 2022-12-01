defmodule SurrealEx.MixProject do
  use Mix.Project

  def project do
    [
      app: :surreal_ex,
      version: "0.1.0",
      elixir: "~> 1.12",
      start_permanent: Mix.env() == :prod,
      deps: deps(),

      # Docs
      name: "SurrealEx",
      source_url: "https://github.com/ricardombiot/SurrealEx",
      docs: [
        main: "SurrealEx", # The main page in the docs
        extras: ["README.md", "guide/custom_queries.md", "guide/quick_crud.md"],
        assets: "guide/assets"
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :httpoison]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:httpoison, "~> 1.8"},
      # In future I would like devs will can choise the JSON parser.
      {:jason, "~> 1.4"},

      # mix docs
      {:earmark, "~> 1.2", only: :dev},
      {:ex_doc, "~> 0.27", only: :dev}

    ]
  end


end
