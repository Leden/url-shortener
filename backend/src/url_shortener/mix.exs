defmodule UrlShortener.MixProject do
  use Mix.Project

  def project do
    [
      app: :url_shortener,
      version: "0.1.0",
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      elixirc_paths: elixirc_paths(Mix.env())
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {UrlShortener.Application, []}
    ]
  end

  defp deps do
    [
      # Dev-only
      {:exsync, "~> 0.2", only: :dev},
      {:credo, "~> 0.10.0", only: [:dev, :test], runtime: false},

      # Test-only
      {:mox, "~> 0.4.0", only: :test},

      # Prod
      {:cowboy, "~> 2.4"},
      {:plug, "~> 1.6"},
      {:poison, "~> 3.0"},
      {:corsica, "~> 1.1"},
      {:ecto, "~> 2.2"},
      {:hashids, "~> 2.0"},
      {:ordered_map, github: "jonnystorm/ordered-map-elixir"}
    ]
  end

  defp elixirc_paths(:test), do: ["test/support", "lib"]
  defp elixirc_paths(_), do: ["lib"]
end
