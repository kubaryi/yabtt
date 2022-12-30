defmodule YaBTT.Types.IPAddress do
  @moduledoc """
  A custom type for IP addresses.
  """

  use Ecto.Type

  @type ip_addr :: :inet.ip_address()

  @doc """
  Returns the underlying schema type for the custom type.
  """
  @spec type :: :binary
  def type, do: :binary

  @doc """
  Casts the given value to an IP address (`ip_addr()`).

  There are two situations where this callback is called:

  1. When casting values by Ecto.Changeset
  2. When passing arguments to Ecto.Query

  It will return `:error` if the given term cannot be cast.

  ## Parameters

    * `ip` - The IP address to cast. The Ip address could be a binary, a
      charlist, or an `ip_addr()`.

  ## Examples

      iex> YaBTT.Types.IPAddress.cast('127.0.0.1')
      {:ok, {127, 0, 0, 1}}

      iex> YaBTT.Types.IPAddress.cast("::1")
      {:ok, {0, 0, 0, 0, 0, 0, 0, 1}}

      iex> YaBTT.Types.IPAddress.cast({127, 0, 0, 1})
      {:ok, {127, 0, 0, 1}}

      iex> YaBTT.Types.IPAddress.cast("abc")
      :error
  """
  @spec cast(binary() | charlist()) :: :error | {:ok, ip_addr()}
  def cast(ip) when is_binary(ip), do: cast(to_charlist(ip))

  def cast(ip) when is_list(ip) do
    case :inet.parse_address(ip) do
      {:ok, ip} -> {:ok, ip}
      {:error, _} -> :error
    end
  end

  @spec cast(ip_addr()) :: {:ok, ip_addr()}
  def cast({_, _, _, _} = ipv4), do: {:ok, ipv4}
  def cast({_, _, _, _, _, _, _, _} = ipv6), do: {:ok, ipv6}
  def cast(_), do: :error

  @doc """
  Loads the IP address from the database.

  This callback is called when loading values from the database.

  It will return `:error` if the given term cannot be loaded.

  ## Parameters

    * `ip` - The IP address to load from the database. It is should be a
      binary in the normal case.

  ## Examples

      iex> YaBTT.Types.IPAddress.load("127.0.0.1")
      {:ok, {127, 0, 0, 1}}
  """
  @spec load(binary()) :: :error | {:ok, ip_addr()}
  def load(ip), do: cast(ip)

  @doc """
  Dumps the IP address to the database.

  This callback is called when dumping values to the database.

  It will return `:error` if the given term cannot be dumped.

  ## Parameters

    * `ip` - The IP address to dump to the database. It should be an
      `ip_addr()`.

  ## Examples

      iex> YaBTT.Types.IPAddress.dump({127, 0, 0, 1})
      {:ok, "127.0.0.1"}

      iex> YaBTT.Types.IPAddress.dump({0, 0, 0, 0, 0, 0, 0, 1})
      {:ok, "::1"}

      iex> YaBTT.Types.IPAddress.dump("abc")
      :error
  """
  @spec dump(ip_addr()) :: :error | {:ok, binary()}
  def dump({_, _, _, _} = ipv4), do: {:ok, do_dump(ipv4)}
  def dump({_, _, _, _, _, _, _, _} = ipv6), do: {:ok, do_dump(ipv6)}
  def dump(_), do: :error

  @spec do_dump(ip_addr()) :: binary()
  defp do_dump(ip), do: :inet.ntoa(ip) |> :erlang.list_to_bitstring()
end
