defmodule YaBTTWeb.Controllers.InfoTest do
  use ExUnit.Case
  use Plug.Test

  doctest YaBTTWeb.Controllers.Info

  alias YaBTTWeb.Controllers.Info

  setup_all do
    {:ok, Info.init([])}
  end

  test "info", opts do
    conn = conn(:get, "/info") |> Info.call(opts)
    [content_type | _tail] = get_resp_header(conn, "content-type")

    assert content_type == "text/html; charset=utf-8"
    assert conn.state == :sent
    assert conn.status == 200
  end
end
