defimpl Bento.Encoder, for: YaBTT.Tracked do
  @moduledoc """
  Implementation of `Bento.Encoder` protocol for `YaBTT.Tracked` struct.
  """

  alias Bento.Encoder
  use Bento.Encode

  @doc """
  Encode the Tracked struct into its Bencoding form.

  ## Parameters
    - track: The `YaBTT.Tracked` struct to be encoded.

  ## Example
      iex> struct(YaBTT.Tracked, %{})
      ...> |> Bento.Encoder.encode()
      ...> |> IO.iodata_to_binary()
      "d10:downloaded4:null5:event4:null9:info_hash4:null2:ip4:null4:left4:null7:peer_id4:null4:port4:null8:uploaded4:nulle"
  """
  @spec encode(YaBTT.Tracked.t()) :: Bento.Encoder.t()
  def encode(track), do: Map.from_struct(track) |> Encoder.Map.encode()
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
  @spec encode(Tuple.t()) :: Bento.Encoder.t()
  def encode(tuple), do: Tuple.to_list(tuple) |> Encoder.List.encode()
end
