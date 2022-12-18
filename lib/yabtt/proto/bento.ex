defimpl Bento.Encoder, for: YaBTT.Proto.Peered do
  @moduledoc """
  Implementation of `Bento.Encoder` protocol for `YaBTT.Proto.Peered` struct.
  """

  alias Bento.Encoder
  alias YaBTT.Proto.Peered
  use Bento.Encode

  @doc """
  Encode the Peered struct into its Bencoding form.

  ## Parameters
    - peer: The `YaBTT.Proto.Peered` struct to be encoded.

  ## Example
      iex> struct(YaBTT.Proto.Peered, %{})
      ...> |> Bento.Encoder.encode()
      ...> |> IO.iodata_to_binary()
      "d2:ip4:null7:peer_id4:null4:port4:nulle"

      iex> struct(YaBTT.Proto.Peered, %{peer_id: "peer_id"})
      ...> |> Bento.Encoder.encode()
      ...> |> IO.iodata_to_binary()
      "d2:ip4:null7:peer_id7:peer_id4:port4:nulle"

  """
  @spec encode(Peered.t()) :: Encoder.t()
  def encode(peer), do: Map.from_struct(peer) |> Encoder.Map.encode()
end

defimpl Bento.Encoder, for: Tuple do
  @moduledoc """
  Implementation of `Bento.Encoder` protocol for `Tuple` struct.
  """

  alias Bento.Encoder
  use Bento.Encode

  @doc """
  Encode the Tuple into its Bencoding form.

  ## Parameters
    - tuple: The `Tuple` to be encoded.

  ## Example
      iex> {1, 2, 3, 4} |> Bento.Encoder.encode() |> IO.iodata_to_binary()
      "li1ei2ei3ei4ee"
  """
  @spec encode(Tuple.t()) :: Encoder.t()
  def encode(tuple), do: Tuple.to_list(tuple) |> Encoder.List.encode()
end
