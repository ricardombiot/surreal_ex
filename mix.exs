defmodule SurrealEx.MixProject do
  use Mix.Project

  def project do
    [
      app: :surreal_ex,
      version: "0.2.0",
      elixir: "~> 1.12",
      description: description(),
      package: package(),
      start_permanent: Mix.env() == :prod,
      deps: deps(),

      # Docs
      name: "SurrealEx",
      source_url: "https://github.com/ricardombiot/surreal_ex",
      docs: [
        main: "readme", # The main page in the docs
        extras: ["README.md",
          "guide/quick_crud.md",
          "guide/custom_queries.md",
          "guide/register_and_login.md"
        ],
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

  defp description do
    "Surreal DB Elixir Library"
  end

  defp package do
    [
      files: [
        "lib",
        "guide",
        "LICENSE",
        "mix.exs",
        "README.md",
      ],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/ricardombiot/surreal_ex"}
    ]
  end


end
