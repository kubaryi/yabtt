defmodule YaBTT.MixProject do
  use Mix.Project

  @source_url "https://github.com/kubaryi/yabtt"
  @version "0.1.4"

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
      {:bento, "~> 1.0"},
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
      ignore_modules: [YaBBT.Application, YaBTT.Repo, YaBTT.Factory, YaBTTWeb],
      summary: [threshold: 85]
    ]
  end

  defp docs do
    [
      main: "readme",
      source_ref: "v#{@version}",
      source_url: @source_url,
      authors: ["Mogeko"],
      extras: [
        "README.md",
        "guides/setup-https.md",
        "guides/compilation-guide.md",
        "guides/examples-and-screenshots.cheatmd",
        "LICENSE",
        "benchmark/README.md": [filename: "benchmark", title: "Benchmark Report"]
      ],
      markdown_processor: {ExDoc.Markdown.Earmark, footnotes: true},
      groups_for_extras: [
        Others: ["LICENSE"]
      ],
      groups_for_modules: [
        # YaBTT,
        # YaBTT.Dec,
        # YaBTT.Deconstruct,
        # YaBTT.Repo,
        # YaBTTWeb.Auth,
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
          YaBTT.CustomTypes.IPAddress
        ],
        "HTTP routing": [
          YaBTTWeb.Router,
          YaBTTWeb.Controllers.Announce,
          YaBTTWeb.Controllers.Scrape,
          YaBTTWeb.Controllers.Info
        ]
      ],
      before_closing_head_tag: &before_closing_head_tag/1
    ]
  end

  # See: https://github.com/elixir-lang/ex_doc/issues/1452#issuecomment-1002222605

  defp before_closing_head_tag(:html) do
    """
    <style>
      a.reversefootnote {display:inline-block;text-indent:-9999px;line-height:0;}
      a.reversefootnote:after {content:'↩';text-indent:0;display:block;line-height:initial;}
    </style>
    """
  end

  defp before_closing_head_tag(_), do: ""
end
