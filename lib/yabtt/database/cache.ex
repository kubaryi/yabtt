defmodule YaBTT.Database.Cache do
  @moduledoc """
  A cache server for storing peer information.
  """

  use GenServer

  @config Application.compile_env(:yabtt, __MODULE__)

  ## Client API

  alias YaBTT.Proto.Peer

  @type opts :: [ets_name: atom(), ets_opts: :ets.options()]
  @type state :: [ets_name: atom()]

  @doc """
  Starts the cache server.

  ## Options

  Set the following options by passing a keyword list
  or by setting in your `config.exs` file:

    * `:ets_name` - The name of the ETS table.
    * `:ets_opts` - The options for the ETS table.
  """
  @spec start_link(opts()) :: GenServer.on_start()
  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, Keyword.merge(@config, opts), name: __MODULE__)
  end

  @doc """
  Updates the cache with the given key and value and returns the list of peers.

  ## Examples

      iex> peer_1 = %YaBTT.Proto.Peered{peer_id: "peer_1", ip: {1, 2, 3, 4}, port: 6881}
      iex> YaBTT.Database.Cache.update_and_get("info_hash", peer_1)
  """
  @spec update_and_get(Peer.info_hash(), Peer.peer()) :: [Peer.peer()]
  def update_and_get(key, value) do
    with :ok <- GenServer.call(__MODULE__, {:put, key, value}) do
      GenServer.call(__MODULE__, {:get, key})
      |> Enum.map(fn {_, peer} -> peer end)
    end
  end

  ## Server callbacks

  @impl true
  @spec init(opts()) :: {:ok, state()} | :ignore
  def init(opts) do
    with {:ok, name} <- Keyword.fetch(opts, :ets_name),
         {:ok, ets_opts} <- Keyword.fetch(opts, :ets_opts) do
      {:ok, [ets_name: :ets.new(name, ets_opts)]}
    else
      _ -> :ignore
    end
  end

  @impl true
  def handle_call({:put, key, value}, _from, state) do
    :ets.insert(state[:ets_name], {key, value})

    {:reply, :ok, state}
  end

  @impl true
  def handle_call({:get, key}, _from, state) do
    {:reply, :ets.lookup(state[:ets_name], key), state}
  end
end
