defprotocol YaBTT.State do
  @moduledoc """
  Protocol for converting normalized data to state.
  """

  alias YaBTT.Norm

  @type statable :: Norm.normalized()
  @type event :: String.t() | nil
  @type peer_id :: String.t()
  @type state :: {String.t(), String.t(), String.t()}
  @type t :: {peer_id, state, event}

  @doc """
  Converts normalized data to state.

  ## Examples

      iex> %{peer_id: "peer_id", downloaded: 100, uploaded: 20, left: 0, event: "started"}
      ...> |> YaBTT.State.to_state()
      {"peer_id", {100, 20, 0}, "started"}

      iex> %{peer_id: "peer_id", downloaded: 100, uploaded: 20, left: 0}
      ...> |> YaBTT.State.to_state()
      {"peer_id", {100, 20, 0}, nil}
  """
  @spec to_state(statable()) :: t()
  def to_state(value)
end

defimpl YaBTT.State, for: Map do
  @moduledoc """
  Implementation of `YaBTT.State` protocol for `Map`.
  """

  alias YaBTT.State

  @available_event ["started", "stopped", "completed", nil]

  @doc """
  Converts normalized data to state.
  """
  @spec to_state(map) :: State.t()
  def to_state(normalized_map) do
    state = {normalized_map[:downloaded], normalized_map[:uploaded], normalized_map[:left]}

    with {:ok, event} <- Map.fetch(normalized_map, :event),
         true <- event in @available_event do
      {normalized_map[:peer_id], state, event}
    else
      _ -> {normalized_map[:peer_id], state, nil}
    end
  end
end
