defmodule YaBTTWeb.Controllers.ScrapeTest do
  use ExUnit.Case
  use Plug.Test

  doctest YaBTTWeb.Controllers.Scrape

  alias YaBTTWeb.Controllers.Scrape

  @default_query_string "info_hash=Nf%22v%BA%CA%0F%DBk%D6%0Bv%17%8C%D1%19%D1%05%00%13"

  setup_all do
    {:ok, Scrape.init([])}
  end

  test "scrape" do
    conn =
      conn(:get, "/scrape")
      |> (&%{&1 | query_string: @default_query_string}).()
      |> Scrape.call([])

    assert String.match?(conn.resp_body, ~r/d5:filesd/)
    assert conn.state == :sent
    assert conn.status == 200
  end
end
