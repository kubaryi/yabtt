use Plug.Test

alias YaBTT.Server.Announce

branch = System.get_env("BENCHMARK_BRANCH", "dev")
opts = Announce.init([])
event_list = ["started", "stopped", "completed", nil]

gen_random_string = fn len -> for _ <- 1..len, into: "", do: <<Enum.random('0123456789abcdef')>> end
gen_info_hash_list = fn len -> for _ <- 1..len, do: gen_random_string.(40) end
gen_peer_id_list = fn len -> for _ <- 1..len, do: gen_random_string.(20) end
gen_faker_header = fn info_hash_list, peer_id_list ->
  %{
    "info_hash" => Enum.random(info_hash_list),
    "peer_id" => Enum.random(peer_id_list),
    "port" => Enum.random(1..65535),
    "uploaded" => Enum.random(0..100),
    "downloaded" => Enum.random(0..100),
    "left" => Enum.random(0..100_000),
    "event" => Enum.random(event_list)
  }
end

Benchee.run(
  %{
    "/announce" => fn {l1, l2} -> conn(:get, "/announce", gen_faker_header.(l1, l2)) |> Announce.call(opts) end,
    "/" => fn _ -> conn(:get, "/", %{}) |> Announce.call(opts) end
  },
  inputs: %{
    "small info_hash list" => {gen_info_hash_list.(30), gen_peer_id_list.(50)},
    "medium info_hash list" => {gen_info_hash_list.(50), gen_peer_id_list.(50)},
    "large info_hash list" => {gen_info_hash_list.(100), gen_peer_id_list.(50)},
  },
  save: [path: "./benchmark/.benchee/benchmark.#{branch}.benchee", tag: branch],
  parallel: 4,
)

Benchee.run(%{}, load: "./benchmark/.benchee/*.benchee")
