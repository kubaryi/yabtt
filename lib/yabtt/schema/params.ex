defmodule YaBTT.Schema.Params do
  @moduledoc """
  The schema for validating the request parameters.

  We only focus on if the required parameters `info_hash` and `peer_id` are
  present. We don't care about the values of these parameters.

  This is an independent embedded schema, witch means all the checking
  happens in the memory and no database operations are involved.
  """

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

  @doc """
  Creates a changeset based on the `struct` and `params`.

  In most cases, `struct` is a `%YaBTT.Schema.Params{}` and the `params`
  is the request parameters.

  ## Parameters

  - `struct`: the changeset struct
  - `params`: the request parameters

  ## Examples

      iex> params = %{"info_hash" => "f0a15e27fafbffc1c2f18f69fcac2dfa461ff4e8", "peer_id" => "-TR14276775888084598"}
      iex> YaBTT.Schema.Params.changeset(%YaBTT.Schema.Params{}, params)
      #Ecto.Changeset<action: nil, changes: %{info_hash: \"f0a15e27fafbffc1c2f18f69fcac2dfa461ff4e8\", peer_id: \"-TR14276775888084598\"}, errors: [], data: #YaBTT.Schema.Params<>, valid?: true>

      iex> params = %{"info_hash" => "f0a15e27fafbffc1c2f18f69fcac2dfa461ff4e8"}
      iex> YaBTT.Schema.Params.changeset(%YaBTT.Schema.Params{}, params)
      #Ecto.Changeset<action: nil, changes: %{info_hash: \"f0a15e27fafbffc1c2f18f69fcac2dfa461ff4e8\"}, errors: [peer_id: {"can't be blank", [validation: :required]}], data: #YaBTT.Schema.Params<>, valid?: false>
  """
  @spec changeset(changeset_t() | t(), params()) :: changeset_t()
  def changeset(struct, params) do
    struct
    |> cast(params, [:info_hash, :peer_id])
    |> validate_required([:info_hash, :peer_id])
  end

  @doc """
  validates the `params` and returns a `YaBTT.Schema.Params` with `:insert` action.

  ## Parameters

  - `params`: the request parameters

  ## Examples

      iex> params = %{"info_hash" => "f0a15e27fafbffc1c2f18f69fcac2dfa461ff4e8", "peer_id" => "-TR14276775888084598"}
      iex> YaBTT.Schema.Params.apply(params)
      {:ok, %YaBTT.Schema.Params{info_hash: "f0a15e27fafbffc1c2f18f69fcac2dfa461ff4e8", peer_id: "-TR14276775888084598"}}

      iex> params = %{"info_hash" => "f0a15e27fafbffc1c2f18f69fcac2dfa461ff4e8"}
      iex> {:error, _} =  YaBTT.Schema.Params.apply(params)
  """
  @spec apply(params()) :: {:ok, t()} | {:error, changeset_t()}
  def apply(params), do: changeset(%__MODULE__{}, params) |> apply_action(:insert)
end
