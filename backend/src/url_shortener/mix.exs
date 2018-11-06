defmodule UrlShortener.MixProject do
  use Mix.Project

  def project do
    [
      app: :url_shortener,
      version: "0.1.0",
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      elixirc_paths: elixirc_paths(Mix.env()),
      test_coverage: [
        tool: Coverex.Task,
        ignore_modules: [
          Poison.Encoder.UrlShortener.Data.Link,
          UrlShortener.Services.Cache.Mock
        ]
      ]
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
      {:credo, "~> 0.10.0", only: [:dev], runtime: false},
      {:dialyxir, "~> 1.0.0-rc.3", only: [:dev], runtime: false},
      {:exsync, "~> 0.2", only: :dev},

      # Test-only
      {:coverex, "~> 1.5", only: :test},
      {:mox, "~> 0.4.0", only: :test},

      # Prod
      {:corsica, "~> 1.1"},
      {:cowboy, "~> 2.4"},
      {:ecto, "~> 2.2"},
      {:hashids, "~> 2.0"},
      {:ordered_map, github: "jonnystorm/ordered-map-elixir"},
      {:plug, "~> 1.6"},
      {:poison, "~> 3.0"},
      {:postgrex, "~> 0.11"}
    ]
  end

  defp elixirc_paths(:test), do: ["test/support", "lib"]
  defp elixirc_paths(_), do: ["lib"]
end
