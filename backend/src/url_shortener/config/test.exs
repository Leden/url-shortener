use Mix.Config

config :url_shortener,
  store_module: UrlShortener.Services.Store.Mock
