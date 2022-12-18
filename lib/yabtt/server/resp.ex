defmodule YaBTT.Server.Resp do
  @moduledoc false

  @enforce_keys [:interval, :peers]
  defstruct interval: 3600, peers: []

  @type peers :: [YaBTT.Proto.Peered.t()]
  @type t :: %__MODULE__{
          interval: integer(),
          peers: peers()
        }

  @doc false
  @spec new(peers()) :: t()
  def new(peers) do
    %__MODULE__{interval: set_interval(), peers: peers}
  end

  @spec set_interval() :: integer()
  defp set_interval() do
    Application.get_env(:yabtt, :interval, 3600)
  end
end
