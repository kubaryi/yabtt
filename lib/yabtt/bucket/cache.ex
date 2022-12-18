defmodule YaBTT.Bucket.Cache do
  @moduledoc false

  use GenServer

  @table :bucket_cache_ets

  @type opts :: [ets_name: atom()]

  ## Client API

  @spec start_link(opts()) :: GenServer.on_start()
  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @spec put(any, any) :: any
  def put(key, value) do
    GenServer.call(__MODULE__, {:put, key, value})
  end

  ## Server callbacks

  @impl true
  @spec init(opts()) :: {:ok, opts()}
  def init(opts) do
    table = Keyword.get(opts, :ets_name, @table)
    ets_opts = [:bag, :named_table, :protected]

    {:ok, [ets_name: :ets.new(table, ets_opts)]}
  end

  @impl true
  def handle_call({:put, key, value}, _from, state) do
    :ets.insert(@table, {key, value})

    {:reply, {:ok, key}, state}
  end
end
