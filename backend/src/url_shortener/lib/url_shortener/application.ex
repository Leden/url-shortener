defmodule UrlShortener.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    start_exsync()

    http_port = Application.get_env(:url_shortener, :http_port)

    children = [
      Plug.Adapters.Cowboy2.child_spec(
        scheme: :http,
        plug: UrlShortener.Http.Router,
        options: [port: http_port]
      ),
      UrlShortener.Services.Store.Impl.child_spec(name: :store)
    ]

    opts = [strategy: :one_for_one, name: UrlShortener.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def start_exsync do
    case Code.ensure_loaded(ExSync) do
      {:module, ExSync = mod} ->
        mod.start()

      {:error, :nofile} ->
        :ok
    end
  end
end
