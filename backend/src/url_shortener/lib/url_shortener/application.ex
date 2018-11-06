defmodule UrlShortener.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    start_exsync()

    opts = [strategy: :one_for_one, name: UrlShortener.Supervisor]
    Supervisor.start_link(children(), opts)
  end

  def start_exsync do
    case Code.ensure_loaded(ExSync) do
      {:module, ExSync = mod} ->
        mod.start()

      {:error, :nofile} ->
        :ok
    end
  end

  def children do
    Application.get_env(:url_shortener, :supervise_children)
  end
end
