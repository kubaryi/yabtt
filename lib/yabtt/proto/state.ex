defmodule Yabtt.Proto.Stated do
  @moduledoc """
  Struct for storing state.
  """

  @enforce_keys [:downloaded, :uploaded, :left]
  defstruct [:downloaded, :uploaded, :left]

  @type t :: %__MODULE__{
          downloaded: integer(),
          uploaded: integer(),
          left: integer()
        }
end

defprotocol YaBTT.Proto.State do
  @moduledoc """
  Protocol for converting parsed data to state.
  """

  alias YaBTT.Proto.Parser

  @type statable :: Parser.parsed()
  @type event :: :started | :stopped | :completed | nil
  @type peer_id :: String.t()
  @type state :: YaBTT.Proto.Stated.t()
  @type t :: {peer_id, state, event}

  @doc """
  Converts parsed data to state.

  ## Examples

      iex> %{peer_id: "peer_id", downloaded: 100, uploaded: 20, left: 0, event: :started}
      ...> |> YaBTT.Proto.State.convert()
      {"peer_id", %Yabtt.Proto.Stated{downloaded: 100, uploaded: 20, left: 0}, :started}

      iex> %{peer_id: "peer_id", downloaded: 100, uploaded: 20, left: 0}
      ...> |> YaBTT.Proto.State.convert()
      {"peer_id", %Yabtt.Proto.Stated{downloaded: 100, uploaded: 20, left: 0}, nil}
  """
  @spec convert(statable()) :: t()
  def convert(value)
end

defimpl YaBTT.Proto.State, for: Map do
  @moduledoc """
  Implementation of `YaBTT.Proto.State` protocol for `Map`.
  """

  alias YaBTT.Proto.{Parser, State}

  @doc """
  Converts parsed data to state.
  """
  @spec convert(Parser.parsed()) :: State.t()
  def convert(parsed_map) do
    state = struct(Yabtt.Proto.Stated, parsed_map)

    case Map.fetch(parsed_map, :event) do
      {:ok, event} -> {parsed_map[:peer_id], state, event}
      _ -> {parsed_map[:peer_id], state, nil}
    end
  end
end
