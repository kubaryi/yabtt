defprotocol YaBTT.State do
  @moduledoc false

  alias Yabtt.Norm

  @type statable :: Norm.normalized()
  @type event :: String.t() | nil
  @type peer_id :: String.t()
  @type state :: {String.t(), String.t(), String.t()}
  @type t :: {peer_id, state, event}

  @spec to_state(statable()) :: t()
  def to_state(value)
end

defimpl YaBTT.State, for: Map do
  @moduledoc false

  alias YaBTT.State

  @available_event ["started", "stopped", "completed", nil]

  @spec to_state(map) :: State.t()
  def to_state(normalized_map) do
    state = {normalized_map[:downloaded], normalized_map[:unloaded], normalized_map[:left]}

    with {:ok, event} <- Map.fetch(normalized_map, :event),
         true <- event in @available_event do
      {normalized_map[:peer_id], state, event}
    else
      _ -> {normalized_map[:peer_id], state, nil}
    end
  end
end
