defmodule YaBTT.Database.Cache do
  @moduledoc false

  use GenServer

  @table Application.compile_env(:yabtt, :track_table_name, :track_bag_ets)

  ## Client API

  alias YaBTT.Proto.Peer

  @type opts :: [ets_name: atom()]
  @type info_hash :: Peer.info_hash()
  @type peer :: Peer.peer()

  @spec start_link(opts()) :: GenServer.on_start()
  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @spec update(info_hash(), peer()) :: [peer()]
  def update(key, value) do
    with :ok <- GenServer.call(__MODULE__, {:put, key, value}) do
      GenServer.call(__MODULE__, {:get, key})
      |> Enum.map(fn {_, peer} -> peer end)
    end
  end

  ## Server callbacks

  @impl true
  @spec init(opts()) :: {:ok, opts()}
  def init(_opts) do
    :ets.new(@table, [:bag, :named_table, :protected])

    {:ok, [ets_name: @table]}
  end

  @impl true
  def handle_call({:put, key, value}, _from, state) do
    :ets.insert(@table, {key, value})

    {:reply, :ok, state}
  end

  @impl true
  def handle_call({:get, key}, _from, state) do
    {:reply, :ets.lookup(@table, key), state}
  end
end
