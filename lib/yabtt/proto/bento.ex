defimpl Bento.Encoder, for: Tuple do
  @moduledoc """
  Implementation of `Bento.Encoder` protocol for `Tuple` struct.
  """

  use Bento.Encode

  alias Bento.Encoder

  @doc """
  Encode the Tuple into its Bencoding form. If the tuple is an IP address,
  it will be encoded as a BitString.

  ## Parameters
    - tuple: The `Tuple` to be encoded.

  ## Example
      iex> {1, 2, 3, 4} |> Bento.Encoder.Tuple.encode() |> IO.iodata_to_binary()
      "7:1.2.3.4"

      iex> {:a, :b, :c, :d} |> Bento.Encoder.Tuple.encode() |> IO.iodata_to_binary()
      "l1:a1:b1:c1:de"
  """
  @spec encode(Tuple.t()) :: Encoder.t()
  def encode(tuple) do
    if :inet.is_ip_address(tuple) do
      :inet.ntoa(tuple) |> to_string() |> Encoder.BitString.encode()
    else
      Tuple.to_list(tuple) |> Encoder.List.encode()
    end
  end
end

defimpl Bento.Encoder, for: YaBTT.Proto.Peered do
  @moduledoc """
  Implementation of `Bento.Encoder` protocol for `YaBTT.Proto.Peered` struct.
  """

  use Bento.Encode

  alias Bento.Encoder
  alias YaBTT.Proto.Peered

  @doc """
  Encode the Peered struct into its Bencoding form.

  ## Parameters
    - peer: The `YaBTT.Proto.Peered` struct to be encoded.

  ## Example
      iex> struct(YaBTT.Proto.Peered, %{})
      ...> |> Bento.Encoder.YaBTT.Proto.Peered.encode()
      ...> |> IO.iodata_to_binary()
      "d2:ip4:null4:port4:null7:peer id4:nulle"

      iex> struct(YaBTT.Proto.Peered, %{peer_id: "peer_id"})
      ...> |> Bento.Encoder.YaBTT.Proto.Peered.encode()
      ...> |> IO.iodata_to_binary()
      "d2:ip4:null4:port4:null7:peer id7:peer_ide"
  """
  @spec encode(Peered.t()) :: Encoder.t()
  def encode(peer) do
    Map.from_struct(peer)
    |> Map.put("peer id", peer.peer_id)
    |> Map.delete(:peer_id)
    |> Encoder.Map.encode()
  end
end

defimpl Bento.Encoder, for: YaBTT.Proto.Response do
  @moduledoc """
  Implementation of `Bento.Encoder` protocol for `YaBTT.Proto.Response` struct.
  """

  use Bento.Encode

  alias Bento.Encoder
  alias YaBTT.Proto.Resp

  @doc """
  Encode the Resp struct into its Bencoding form.

  ## Parameters
    - resp: The `YaBTT.Proto.Response` struct to be encoded.

  ## Example
      iex> struct(YaBTT.Proto.Response, %{})
      ...> |> Bento.Encoder.YaBTT.Proto.Response.encode()
      ...> |> IO.iodata_to_binary()
      "d8:intervali3600e5:peerslee"

      iex> %YaBTT.Proto.Response{
      ...>   interval: 3600,
      ...>   peers: [
      ...>     %YaBTT.Proto.Peered{peer_id: "peer_id", ip: {1, 2, 3, 4}, port: 6881}
      ...>   ]
      ...> } |> Bento.Encoder.YaBTT.Proto.Response.encode() |> IO.iodata_to_binary()
      "d8:intervali3600e5:peersld2:ip7:1.2.3.44:porti6881e7:peer id7:peer_ideee"
  """
  @spec encode(Resp.t()) :: Encoder.t()
  def encode(resp), do: Map.from_struct(resp) |> Encoder.Map.encode()
end

alias YaBTT.Errors.InvalidRequeste
alias YaBTT.Errors.Refused
alias YaBTT.Errors.Timeout

defimpl Bento.Encoder, for: [InvalidRequeste, Refused, Timeout] do
  @moduledoc """
  Implementation of `Bento.Encoder` protocol for Exception structs.
  """

  use Bento.Encode

  alias Bento.Encoder

  @type error :: InvalidRequeste.t() | Refused.t() | Timeout.t()

  @doc """
  Encode the Exception into its Bencoding form.

  ## Parameters
    - err: The Exception struct to be encoded.

  ## Example

      iex> %YaBTT.Errors.InvalidRequeste{}
      ...> |> Bento.Encoder.YaBTT.Errors.InvalidRequeste.encode()
      ...> |> IO.iodata_to_binary()
      "d14:failure reason15:invalid requeste"

      iex> %YaBTT.Errors.Refused{}
      ...> |> Bento.Encoder.YaBTT.Errors.Refused.encode()
      ...> |> IO.iodata_to_binary()
      "d14:failure reason18:connection refusede"

      iex> %YaBTT.Errors.Timeout{}
      ...> |> Bento.Encoder.YaBTT.Errors.Timeout.encode()
      ...> |> IO.iodata_to_binary()
      "d14:failure reason19:operation timed oute"
  """
  @spec encode(Error.t()) :: Encoder.t()
  def encode(err) do
    %{"failure reason" => err.message} |> Encoder.Map.encode()
  end
end
