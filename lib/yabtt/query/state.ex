defmodule YaBTT.Query.State do
  @moduledoc false

  import Ecto.Query

  alias YaBTT.Schema.{Connection, Torrent}

  @type id :: integer() | binary()

  defmacrop count_complete do
    quote do
      count(
        fragment(
          "CASE WHEN left <= 0 AND event == ? THEN 1 END",
          <<115, 116, 97, 114, 116, 101, 100>>
        )
      )
    end
  end

  defmacrop count_incomplete do
    quote do
      count(
        fragment(
          "CASE WHEN left > 0 AND event == ? THEN 1 END",
          <<115, 116, 97, 114, 116, 101, 100>>
        )
      )
    end
  end

  defmacrop count_downloaded do
    quote do
      count(
        fragment(
          "CASE WHEN left <= 0 OR event == ? THEN 1 END",
          <<99, 111, 109, 112, 108, 101, 116, 101, 100>>
        )
      )
    end
  end

  @doc false
  @spec query([id()]) :: Ecto.Query.t()
  def query(info_hashs) do
    from(
      c in Connection,
      inner_join: t in Torrent,
      on: c.torrent_id == t.id,
      where: t.info_hash in ^info_hashs,
      group_by: t.info_hash,
      select: %{
        t.info_hash => %{
          "complete" => count_complete(),
          "incomplete" => count_incomplete(),
          "downloaded" => count_downloaded()
        }
      }
    )
    |> YaBTT.Repo.all()
  end
end
