defmodule UrlShortener.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  # @store Application.get_env :url_shortener, :store_module

  def start(_type, _args) do
    start_exsync()

    # List all child processes to be supervised
    children = [
      # Starts a worker by calling: UrlShortener.Worker.start_link(arg)
      # {UrlShortener.Worker, arg},
      Plug.Adapters.Cowboy2.child_spec(
        scheme: :http,
        plug: UrlShortener.Http.Router,
        options: [port: 8080] # TODO: parametrize port
      ),
      # UrlShortener.Services.Store.child_spec([name: :store])
      UrlShortener.Services.Store.Impl.child_spec([name: :store])
      # @store.child_spec([name: :store])
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
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
