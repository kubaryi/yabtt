defmodule YaBTT.MixProject do
  use Mix.Project

  def project do
    [
      app: :yabtt,
      version: "0.0.1-beta",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {YaBTT.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:benchee, "~> 1.1.0", only: :dev},
      {:benchee_html, "~> 1.0", only: :dev},
      {:plug_cowboy, "~> 2.6.0"},
      {:ecto_sql, "~> 3.0"},
      {:postgrex, "~> 0.16"},
      {:bento, "~> 0.9"}
    ]
  end
end
