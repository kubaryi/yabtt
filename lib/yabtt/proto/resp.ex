defmodule YaBTT.Proto.Response do
  @moduledoc """
  Response struct for the `/announce` endpoint.

  ## Example

  The `interval` key is set to 3600 by default. The `peers` key is required,
  but we won't check its type of values.

      iex> %YaBTT.Proto.Response{interval: 3000, peers: []}
      %YaBTT.Proto.Response{interval: 3000, peers: []}

      iex> %YaBTT.Proto.Response{peers: []}
      %YaBTT.Proto.Response{interval: 3600, peers: []}
  """

  @enforce_keys [:peers]
  defstruct interval: 3600, peers: []

  @type peers :: [YaBTT.Proto.Peered.t()]
  @type t :: %__MODULE__{
          interval: integer(),
          peers: peers()
        }
end

defprotocol YaBTT.Proto.Resp do
  @moduledoc """
  Protocol for handling the `YaBTT.Proto.Response`.
  """

  @type t :: YaBTT.Proto.Response.t()

  @doc """
  Generate a `YaBTT.Proto.Response` struct.

  Set the `:peers` by parameter.

  Set the `:interval` by the environment variable `YABTT_INTERVAL`
  or 3600 by default.

  ## Example

      iex> [%YaBTT.Proto.Peered{peer_id: "peer_id", ip: {1,2,3,4}, port: 6881}]
      ...> |> YaBTT.Proto.Resp.new()
      %YaBTT.Proto.Response{
        interval: 3600,
        peers: [
          %YaBTT.Proto.Peered{
            peer_id: "peer_id",
            ip: {1,2,3,4},
            port: 6881
          }
        ]
      }
  """
  @spec new(Response.peers()) :: Response.t()
  def new(peers)
end

defimpl YaBTT.Proto.Resp, for: List do
  @moduledoc """
  Implementation for `YaBTT.Proto.Resp` protocol.
  """

  alias YaBTT.Proto.Response

  @doc """
  Generate a `YaBTT.Proto.Response` struct.
  """
  @spec new(Response.peers()) :: Response.t()
  def new(peers) do
    %Response{
      interval: Application.get_env(:yabtt, :interval, 3600),
      peers: peers
    }
  end
end
