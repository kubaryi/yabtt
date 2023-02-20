defimpl Bento.Encoder, for: Tuple do
  @moduledoc """
  Implementation of `Bento.Encoder` protocol for `Tuple` struct.

  We will analyze whether the `Tuple` is an IP address, and encode it into a
  `BitString` if it is. Otherwise, we will encode it into a `List`.
  """

  alias Bento.Encoder

  @doc """
  Encode the Tuple into its Bencoding form.

  ## Parameters
    - tuple: The `Tuple` to be encoded.

  ## Example

      iex> {1, 2, 3, 4} |> Bento.Encoder.Tuple.encode() |> IO.iodata_to_binary()
      "7:1.2.3.4"

      iex> {0, 0, 0, 0, 0, 0, 0, 1} |> Bento.Encoder.Tuple.encode() |> IO.iodata_to_binary()
      "3:::1"

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
