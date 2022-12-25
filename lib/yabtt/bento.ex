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
    Tuple.to_list(tuple) |> Encoder.List.encode()
  end
end
