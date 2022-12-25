defmodule YaBTT.Schema.Params do
  @moduledoc """
  The schema for validating the request parameters.

  We only focus on if the required parameters `info_hash`, `peer_id`,
  `port`, `uploaded`, `downloaded` and `left` are present. We don't
  care about the values of these parameters.

  This is an independent embedded schema, witch means all the checking
  happens in the memory and no database operations are involved.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  embedded_schema do
    field(:info_hash, :binary)
    field(:peer_id, :binary)
    field(:ip, :binary)
    field(:port, :integer)
    field(:uploaded, :integer)
    field(:downloaded, :integer)
    field(:left, :integer)
    field(:event, :binary)
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

      iex> params = %{
      ...>   "info_hash" => "f0a15e27fafbffc1c2f18f69fcac2dfa461ff4e8",
      ...>   "peer_id" => "-TR14276775888084598",
      ...>   "port" => "6881",
      ...>   "uploaded" => "121",
      ...>   "downloaded" => "41421",
      ...>   "left" => "0"
      ...> }
      iex> YaBTT.Schema.Params.changeset(%YaBTT.Schema.Params{}, params)

      iex> params = %{"info_hash" => "f0a15e27fafbffc1c2f18f69fcac2dfa461ff4e8"}
      iex> YaBTT.Schema.Params.changeset(%YaBTT.Schema.Params{}, params)
  """
  @spec changeset(changeset_t() | t(), params()) :: changeset_t()
  def changeset(struct, params) do
    struct
    |> cast(params, [:info_hash, :peer_id, :ip, :port, :uploaded, :downloaded, :left, :event])
    |> validate_required([:info_hash, :peer_id, :port, :uploaded, :downloaded, :left])
    |> validate_event()
  end

  alias YaBTT.{Schema.Peer, Repo}

  @spec validate_event(changeset_t()) :: changeset_t()
  defp validate_event(changeset) do
    with {:data, nil} <- fetch_field(changeset, :event),
         {:ok, peer_id} <- fetch_change(changeset, :peer_id),
         nil <- Repo.get_by(Peer, peer_id: peer_id) do
      add_error(changeset, :event, "can't be blank for new peers", validation: :event)
    else
      _ -> changeset
    end
  end

  @doc """
  validates the `params` and returns a `YaBTT.Schema.Params` with `:insert` action.

  ## Parameters

  - `params`: the request parameters

  ## Examples

      iex> %{
      ...>   "info_hash" => "f0a15e27fafbffc1c2f18f69fcac2dfa461ff4e8",
      ...>   "peer_id" => "-TR14276775888084598",
      ...>   "ip" => "127.0.0.1",
      ...>   "port" => "6881",
      ...>   "uploaded" => "121",
      ...>   "downloaded" => "41421",
      ...>   "left" => "0",
      ...>   "event" => "completed"
      ...> } |> YaBTT.Schema.Params.apply()
      {:ok,
        %YaBTT.Schema.Params{
          info_hash: "f0a15e27fafbffc1c2f18f69fcac2dfa461ff4e8",
          peer_id: "-TR14276775888084598",
          ip: "127.0.0.1",
          port: 6881,
          uploaded: 121,
          downloaded: 41421,
          left: 0,
          event: "completed"
        }
      }

      iex> params = %{"info_hash" => "f0a15e27fafbffc1c2f18f69fcac2dfa461ff4e8"}
      iex> {:error, _} =  YaBTT.Schema.Params.apply(params)
  """
  @spec apply(params()) :: {:ok, t()} | {:error, changeset_t()}
  def apply(params), do: changeset(%__MODULE__{}, params) |> apply_action(:insert)
end
