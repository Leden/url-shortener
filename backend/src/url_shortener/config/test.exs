use Mix.Config

config :url_shortener,
  cache_module: UrlShortener.Services.Cache.Mock,
  supervise_children: []
