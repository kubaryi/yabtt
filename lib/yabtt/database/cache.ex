defmodule YaBTT.Database.Cache do
  @moduledoc false

  use GenServer

  @config Application.compile_env(:yabtt, __MODULE__)

  ## Client API

  alias YaBTT.Proto.Peer

  @type opts :: [ets_name: atom(), ets_opts: :ets.options()]
  @type state :: [ets_name: atom()]

  @spec start_link(opts()) :: GenServer.on_start()
  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, Keyword.merge(@config, opts), name: __MODULE__)
  end

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
