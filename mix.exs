defmodule YaBTT.MixProject do
  use Mix.Project

  @version "0.0.1"
  @source_url "https://github.com/mogeko/yabtt"

  def project do
    [
      app: :yabtt,
      version: @version,
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      test_coverage: test_coverage(),
      aliases: aliases(),

      # Docs
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
      {:benchee, "~> 1.1.0", only: :dev},
      {:benchee_html, "~> 1.0", only: :dev},
      {:bento, "~> 0.9"},
      {:ecto_sql, "~> 3.8"},
      {:ecto_sqlite3, "~> 0.8"},
      {:ex_doc, "~> 0.29", only: :dev, runtime: false},
      {:plug_cowboy, "~> 2.6.0"}
    ]
  end

  defp aliases do
    [
      "ecto.setup": ["ecto.create", "ecto.migrate"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate", "test"]
    ]
  end

  defp test_coverage do
    [
      ignore_modules: [YaBBT.Application, YaBTT.Repo],
      summary: [threshold: 85]
    ]
  end

  defp docs do
    [
      main: "readme",
      extras: ["README.md", "LICENSE"],
      source_url: @source_url
    ]
  end
end
