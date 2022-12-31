defimpl Bento.Encoder, for: Tuple do
  @moduledoc """
  Implementation of `Bento.Encoder` protocol for `Tuple` struct.
  """

  use Bento.Encode

  alias Bento.Encoder

  @doc """
  Encode the Tuple into its Bencoding form.
  ## Parameters
    - tuple: The `Tuple` to be encoded.
  ## Example
      iex> {:a, :b, :c, :d} |> Bento.Encoder.Tuple.encode() |> IO.iodata_to_binary()
      "l1:a1:b1:c1:de"
  """
  @spec encode(Tuple.t()) :: Encoder.t()
  def encode(tuple) do
    if :inet.is_ip_address(tuple) do
      tuple |> :inet.ntoa() |> to_string() |> Encoder.BitString.encode()
    else
      tuple |> Tuple.to_list() |> Encoder.List.encode()
    end
  end
end
