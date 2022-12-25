defmodule YaBTT.Schema.Params do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  embedded_schema do
    field(:info_hash, :binary)
    field(:peer_id, :binary)
  end

  @type t :: %__MODULE__{}
  @type changeset_t :: Ecto.Changeset.t(t())
  @type params :: map()

  @doc false
  @spec changeset(changeset_t() | t(), params()) :: changeset_t()
  def changeset(struct, params) do
    struct
    |> cast(params, [:info_hash, :peer_id])
    |> validate_required([:info_hash, :peer_id])
  end

  @doc false
  @spec apply(params()) :: {:ok, t()} | {:error, changeset_t()}
  def apply(params), do: changeset(%__MODULE__{}, params) |> apply_action(:insert)
end
