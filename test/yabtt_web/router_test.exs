defmodule YaBTTWeb.RouterTest do
  use ExUnit.Case
  use Plug.Test

  alias YaBTTWeb.Router

  setup_all do
    {:ok, Router.init([])}
  end

  test "GET /", opts do
    conn =
      conn(:get, "https://example.com/")
      # replace `put_req_header/3`
      |> set_req_header("host", "example.com")
      |> Router.call(opts)

    assert conn.state == :sent
    assert conn.status == 200
  end

  test "GET /announce" do
    conn = conn(:get, "https://example.com/announce") |> Router.call([])

    assert conn.state == :sent
  end

  test "GET /scrape" do
    conn = conn(:get, "https://example.com/scrape") |> Router.call([])

    assert conn.state == :sent
  end

  test "GET /info" do
    conn = conn(:get, "https://example.com/info") |> Router.call([])

    assert conn.state == :sent
  end

  test "GRT /stats" do
    conn = conn(:get, "https://example.com/stats") |> Router.call([])

    assert conn.state == :sent
  end

  test "Returns 404", opts do
    conn = conn(:get, "https://example.com/missing", %{}) |> Router.call(opts)

    assert conn.state == :sent
    assert conn.status == 404
  end

  # Set (put) the request header with the given key and value.
  #
  # Replace the `put_req_header/3` to avoid the following error:
  #
  #   ** (Plug.Conn.InvalidHeaderError) set the host header with %Plug.Conn{conn | host: "example.com"}
  #   code: |> put_req_header("host", "example.com")
  #   stacktrace:
  #     (plug 1.14.0) lib/plug/conn.ex:1890: Plug.Conn.validate_req_header!/2
  #     (plug 1.14.0) lib/plug/conn.ex:787: Plug.Conn.put_req_header/3
  #     test/yabtt/server/router_test.exs:14: (test)
  defp set_req_header(conn, key, value) do
    %Plug.Conn{conn | req_headers: [{key, value} | conn.req_headers]}
  end
end
