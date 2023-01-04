defmodule YaBTT.Schema.Announce do
  @moduledoc """
  The schema for validating the request parameters for routing `/announce`.

  We only focus on if the required parameters `info_hash` and `peer_id` are
  present. We don't check if the `info_hash` and `peer_id` are valid. At the
  same time, if the environment variables `YABTT_COMPACT_ONLY` being set to
  `true`, we will **refuse the request** if the request contains `compact=0`.

  This is an independent embedded schema, witch means all the checking
  happens in the memory and no database operations are involved.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  embedded_schema do
    field(:info_hash, :binary)
    field(:peer_id, :binary)
    field(:compact, :integer, default: 0)
    field(:no_peer_id, :integer, default: 0)
  end

  @type t :: %__MODULE__{}
  @type changeset_t :: Ecto.Changeset.t(t())
  @type params :: map()

  @doc """
  Creates a changeset based on the `struct` and `params`.

  In most cases, `struct` is a `%YaBTT.Schema.Announce{}` and the `params`
  is the request parameters.

  ## Parameters

  - `struct`: the changeset struct
  - `params`: the request parameters

  ## Examples

      iex> params = %{"info_hash" => "f0a15e27fafbffc1c2f1", "peer_id" => "-TR14276775888084598"}
      iex> YaBTT.Schema.Announce.changeset(%YaBTT.Schema.Announce{}, params)

      iex> params = %{"info_hash" => "f0a15e27fafbffc1c2f1"}
      iex> YaBTT.Schema.Announce.changeset(%YaBTT.Schema.Announce{}, params)
  """
  @spec changeset(changeset_t() | t(), params()) :: changeset_t()
  def changeset(struct, params) do
    struct
    |> cast(params, [:info_hash, :peer_id, :compact, :no_peer_id])
    |> validate_required([:info_hash, :peer_id])
    |> validate_compact(params)
  end

  @spec validate_compact(changeset_t(), params()) :: changeset_t()
  defp validate_compact(changeset, params) do
    with true <- Application.get_env(:yabtt, :compact_only, false),
         {:ok, "0"} <- Map.fetch(params, "compact") do
      add_error(changeset, :compact, "connection refused", validation: :compact)
    else
      :error -> change(changeset, compact: 1)
      _ -> changeset
    end
  end

  @doc """
  validates the `params` and returns a `YaBTT.Schema.Announce` with `:insert` action.

  ## Parameters

  - `params`: the request parameters

  ## Examples

      iex> %{"info_hash" => "f0a15e27fafbffc1c2f1", "peer_id" => "-TR14276775888084598"}
      ...> |> YaBTT.Schema.Announce.apply()
      {:ok, %YaBTT.Schema.Announce{info_hash: "f0a15e27fafbffc1c2f1", peer_id: "-TR14276775888084598"}}

      iex> params = %{"info_hash" => "f0a15e27fafbffc1c2f18f69fcac2dfa461ff4e8"}
      iex> {:error, _} =  YaBTT.Schema.Announce.apply(params)
  """
  @spec apply(params()) :: {:ok, t()} | {:error, changeset_t()}
  def apply(params), do: changeset(%__MODULE__{}, params) |> apply_action(:insert)
end
