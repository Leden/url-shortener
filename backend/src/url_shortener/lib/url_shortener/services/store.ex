defmodule UrlShortener.Services.Store do
  @callback create(store :: term(), link :: Data.Link.t()) :: :ok
  @callback get_all(store :: term()) :: [Data.Link.t()]
  @callback delete(store :: term(), code :: String.t()) :: :ok
  @callback get(store :: term(), code :: String.t()) :: {:ok, Data.Link.t()} | :error
  @callback get_last_code(store :: term()) :: String.t() | nil
end

defmodule UrlShortener.Services.Store.Impl do
  # TODO: preserve creation order
  @behaviour UrlShortener.Services.Store
  use GenServer

  alias UrlShortener.Data

  def start_link(opts) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  @spec create(store :: term(), link :: Data.Link.t()) :: :ok
  def create(store, link) do
    GenServer.call(store, {:create, link})
  end

  @spec get_all(store :: term()) :: [Data.Link.t()]
  def get_all(store) do
    GenServer.call(store, :get_all)
  end

  @spec delete(store :: term(), code :: String.t()) :: :ok
  def delete(store, code) do
    GenServer.call(store, {:delete, code})
  end

  @spec get(store :: term(), code :: String.t()) :: {:ok, Data.Link.t()} | :error
  def get(store, code) do
    GenServer.call(store, {:get, code})
  end

  @spec get_last_code(store :: term()) :: String.t() | nil
  def get_last_code(store) do
    GenServer.call(store, :get_last_code)
  end

  ## Server Callbacks

  defmodule State do
    @enforce_keys [:dict, :last_code]
    defstruct [:dict, :last_code]
  end

  def init(:ok) do
    {:ok, %State{dict: %{}, last_code: nil}}
  end

  def handle_call({:create, %{code: code} = link}, _from, state) do
    {:reply, :ok, %State{state | dict: Map.put(state.dict, code, link), last_code: code}}
  end

  def handle_call(:get_all, _from, state) do
    {:reply, Map.values(state.dict), state}
  end

  def handle_call({:delete, code}, _from, state) do
    {:reply, :ok, %State{state | dict: Map.delete(state.dict, code)}}
  end

  def handle_call({:get, code}, _from, state) do
    {:reply, Map.fetch(state.dict, code), state}
  end

  def handle_call(:get_last_code, _from, %State{last_code: last_code} = state) do
    {:reply, last_code, state}
  end
end
