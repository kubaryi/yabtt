defmodule YaBTT.Types.IPAddress do
  @moduledoc false

  use Ecto.Type

  @type ip_addr :: :inet.ip_address()

  @doc false
  @spec type :: :binary
  def type, do: :binary

  @doc false
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

  @doc false
  @spec load(binary()) :: :error | {:ok, ip_addr()}
  def load(ip), do: cast(ip)

  @doc false
  @spec dump(ip_addr()) :: :error | {:ok, binary()}
  def dump({_, _, _, _} = ipv4), do: {:ok, do_dump(ipv4)}
  def dump({_, _, _, _, _, _, _, _} = ipv6), do: {:ok, do_dump(ipv6)}
  def dump(_), do: :error

  @spec do_dump(ip_addr()) :: binary()
  defp do_dump(ip), do: :inet.ntoa(ip) |> :erlang.list_to_bitstring()
end
