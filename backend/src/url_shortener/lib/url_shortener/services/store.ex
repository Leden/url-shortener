defmodule UrlShortener.Services.Store do
  @moduledoc """
  Behaviour describing the Store interface.
  """
  alias UrlShortener.Data.Link

  @callback create(store :: term(), link :: Link.t()) :: :ok
  @callback get_all(store :: term()) :: [Link.t()]
  @callback delete(store :: term(), code :: String.t()) :: :ok
  @callback get(store :: term(), code :: String.t()) :: {:ok, Link.t()} | :error
  @callback get_last_code(store :: term()) :: String.t() | nil
end

defmodule UrlShortener.Services.Store.Impl do
  @moduledoc """
  Stores the Links in memory.
  """
  @behaviour UrlShortener.Services.Store
  use GenServer

  alias UrlShortener.Data.Link

  def start_link(opts) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  @spec create(store :: term(), link :: Link.t()) :: :ok
  def create(store, link) do
    GenServer.call(store, {:create, link})
  end

  @spec get_all(store :: term()) :: [Link.t()]
  def get_all(store) do
    GenServer.call(store, :get_all)
  end

  @spec delete(store :: term(), code :: String.t()) :: :ok
  def delete(store, code) do
    GenServer.call(store, {:delete, code})
  end

  @spec get(store :: term(), code :: String.t()) :: {:ok, Link.t()} | :error
  def get(store, code) do
    GenServer.call(store, {:get, code})
  end

  @spec get_last_code(store :: term()) :: String.t() | nil
  def get_last_code(store) do
    GenServer.call(store, :get_last_code)
  end

  ## Server Callbacks

  def init(:ok) do
    {:ok, OrderedMap.new()}
  end

  def handle_call({:create, %Link{code: code} = link}, _from, state) do
    {:reply, :ok, OrderedMap.put(state, code, link)}
  end

  def handle_call(:get_all, _from, state) do
    {:reply, OrderedMap.values(state), state}
  end

  def handle_call({:delete, code}, _from, state) do
    {:reply, :ok, OrderedMap.delete(state, code)}
  end

  def handle_call({:get, code}, _from, state) do
    {:reply, OrderedMap.fetch(state, code), state}
  end

  def handle_call(:get_last_code, _from, state) do
    last_code =
      case state.keys do
        [] -> nil
        [code | _] -> code
      end

    {:reply, last_code, state}
  end
end
