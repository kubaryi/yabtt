defmodule Bench do
  @moduledoc false

  use Plug.Test

  alias YaBTTWeb.Router

  @save_dir System.get_env("BENCHMARK_SAVE_DIR", "./benchmark/.benchee")
  @report_dir System.get_env("BENCHMARK_REPORT_DIR", "./benchmark/report")
  Enum.map([@save_dir, @report_dir], &File.mkdir_p(&1))

  @utc DateTime.utc_now() |> DateTime.to_string()

  @doc false
  def run do
    Benchee.run(benchmark_helper(),
      inputs: input_helper(),
      save: [path: "#{@save_dir}/#{get_branch()}.#{@utc}.benchee", tag: get_branch()],
      formatters: [
        {Benchee.Formatters.HTML, file: "#{@report_dir}/index.html", auto_open: false},
        Benchee.Formatters.Console
      ]
    )
  end

  def diff, do: Benchee.run(%{}, load: "#{@save_dir}/*.benchee")

  defp benchmark_helper do
    %{
      "small number of users" => call_announce(100),
      "moderate number of users" => call_announce(1_000),
      "large number of users" => call_announce(10_000)
    }
  end

  defp input_helper do
    %{
      "small amount of BitTorrent" => gen_rand_binary_list(100),
      "medium number of BitTorrent" => gen_rand_binary_list(1_000),
      "large number of BitTorrent" => gen_rand_binary_list(10_000)
    }
  end

  defp gen_fake_header(info_hash_list, peer_id_list) do
    %{
      "info_hash" => Enum.random(info_hash_list),
      "peer_id" => Enum.random(peer_id_list),
      "port" => Enum.random(1..65535),
      "uploaded" => Enum.random(0..100),
      "downloaded" => Enum.random(0..100),
      "left" => Enum.random(0..100_000),
      "event" => Enum.random(["started", "stopped"]),
      "compact" => Enum.random([0, 1]),
      "no_peer_id" => Enum.random([0, 1])
    }
  end

  @tag System.get_env("BENCHMARK_TAG", nil)

  defp get_branch do
    with {b, 0} <- System.cmd("git", ["branch", "--show-current"]) do
      @tag || b |> String.trim()
    else
      _ -> @tag
    end
  end

  @url "https://example.com/announce"
  @opts Router.init([])

  defp call_announce(x) do
    peer_id_list = gen_rand_binary_list(x)

    fn info_hash_list ->
      conn(:get, @url, gen_fake_header(info_hash_list, peer_id_list))
      |> Router.call(@opts)
    end
  end

  defp gen_rand_binary_list(len) do
    for _ <- 1..len, do: :crypto.strong_rand_bytes(20)
  end
end

Bench.run()
