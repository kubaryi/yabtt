defprotocol YaBTT.Proto.State do
  @moduledoc """
  Protocol for converting parsed data to state.
  """

  alias YaBTT.Proto.Parser

  @type statable :: Parser.parsed()
  @type event :: String.t() | nil
  @type peer_id :: String.t()
  @type state :: {String.t(), String.t(), String.t()}
  @type t :: {peer_id, state, event}

  @doc """
  Converts parsed data to state.

  ## Examples

      iex> %{peer_id: "peer_id", downloaded: 100, uploaded: 20, left: 0, event: "started"}
      ...> |> YaBTT.Proto.State.convert()
      {"peer_id", {100, 20, 0}, "started"}

      iex> %{peer_id: "peer_id", downloaded: 100, uploaded: 20, left: 0}
      ...> |> YaBTT.Proto.State.convert()
      {"peer_id", {100, 20, 0}, nil}
  """
  @spec convert(statable()) :: t()
  def convert(value)
end

defimpl YaBTT.Proto.State, for: Map do
  @moduledoc """
  Implementation of `YaBTT.Proto.State` protocol for `Map`.
  """

  alias YaBTT.Proto.State

  @available_event ["started", "stopped", "completed", nil]

  @doc """
  Converts parsed data to state.
  """
  @spec convert(map) :: State.t()
  def convert(parsed_map) do
    state = {parsed_map[:downloaded], parsed_map[:uploaded], parsed_map[:left]}

    with {:ok, event} <- Map.fetch(parsed_map, :event),
         true <- event in @available_event do
      {parsed_map[:peer_id], state, event}
    else
      _ -> {parsed_map[:peer_id], state, nil}
    end
  end
end
