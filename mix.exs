defmodule YaBTT.MixProject do
  use Mix.Project

  @source_url "https://github.com/mogeko/yabtt"
  @version "0.0.6"

  def project do
    [
      app: :yabtt,
      version: @version,
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      elixirc_paths: elixirc_paths(Mix.env()),
      test_coverage: test_coverage(),
      aliases: aliases(),

      # Documents
      name: "YaBTT",
      docs: docs()
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {YaBTT.Application, []}
    ]
  end

  defp deps do
    [
      {:benchee, "~> 1.1.0", only: [:dev, :bench]},
      {:benchee_html, "~> 1.0", only: [:dev, :bench]},
      {:bento, "~> 0.9"},
      {:ecto_sql, "~> 3.8"},
      {:ecto_sqlite3, "~> 0.8"},
      {:ex_doc, "~> 0.29", only: :dev, runtime: false},
      {:plug_cowboy, "~> 2.6.0"},
      {:x509, "~> 0.8", only: :dev}
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp aliases do
    [
      "ecto.setup": ["ecto.create", "ecto.migrate"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate", "test"]
    ]
  end

  defp test_coverage do
    [
      ignore_modules: [YaBBT.Application, YaBTT.Repo, YaBTT.Factory],
      summary: [threshold: 85]
    ]
  end

  defp docs do
    [
      main: "readme",
      source_ref: "master",
      source_url: @source_url,
      authors: ["Mogeko"],
      extras: [
        "README.md",
        "guides/compilation-guide.md",
        "guides/setup-https.md",
        "guides/examples-and-screenshots.cheatmd",
        "LICENSE"
      ],
      markdown_processor: {ExDoc.Markdown.Earmark, footnotes: true},
      groups_for_extras: [
        Others: ["LICENSE"]
      ],
      groups_for_modules: [
        # YaBTT,
        # YaBTT.Repo,
        Query: [
          YaBTT.Query.State,
          YaBTT.Query.Peers
        ],
        "Schema for Database": [
          YaBTT.Schema.Connection,
          YaBTT.Schema.Announce,
          YaBTT.Schema.Peer,
          YaBTT.Schema.Torrent
        ],
        "Database Types": [
          YaBTT.Types.Event,
          YaBTT.Types.IPAddress
        ],
        "HTTP routing": [
          YaBTT.Server.Router,
          YaBTT.Server.Announce,
          YaBTT.Server.Scrape
        ]
      ]
    ]
  end
end
