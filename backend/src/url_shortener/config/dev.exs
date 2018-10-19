use Mix.Config

config :logger,
  backends: [:console],
  level: :debug

config :url_shortener,
  corsica: [
    origins: "*",
    allow_headers: :all,
    log: [
      rejected: :warn,
      invalid: :debug,
      accepted: :debug
    ]
  ]
