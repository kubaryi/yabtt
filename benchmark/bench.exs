use Plug.Test

alias YaBTT.Server.Router

# Environment variables
tag = System.get_env("BENCHMARK_TAG", nil)
save_dir = System.get_env("BENCHMARK_SAVE_DIR", "./benchmark/.benchee")
report_dir = System.get_env("BENCHMARK_REPORT_DIR", "./benchmark/report")

branch =
  with {b, 0} <- System.cmd("git", ["branch", "--show-current"]) do
    tag || b |> String.trim()
  else
    _ -> tag
  end

Enum.map([save_dir, report_dir], &File.mkdir_p(&1))
utc = DateTime.utc_now() |> DateTime.to_string()
opts = Router.init([])

# Benchmark helper functions
gen_random_string = fn len ->
  for _ <- 1..len, into: "", do: <<Enum.random('0123456789abcdef')>>
end

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
    "event" => Enum.random(["started", "stopped", "completed"])
  }
end

call_announce = fn i, l2 ->
  conn(:get, "/announce", gen_faker_header.(i, l2)) |> Router.call(opts)
end

# Benchmark Data
peer_id_list_1 = gen_peer_id_list.(100)
peer_id_list_2 = gen_peer_id_list.(1_000)
peer_id_list_3 = gen_peer_id_list.(10_000)

# Benchmark
Benchee.run(
  %{
    "small number of users" => fn i -> call_announce.(i, peer_id_list_1) end,
    "moderate number of users" => fn i -> call_announce.(i, peer_id_list_2) end,
    "large number of users" => fn i -> call_announce.(i, peer_id_list_3) end
  },
  inputs: %{
    "small amount of BitTorrent" => gen_info_hash_list.(100),
    "medium number of BitTorrent" => gen_info_hash_list.(1_000),
    "large number of BitTorrent" => gen_info_hash_list.(10_000)
  },
  save: [path: "#{save_dir}/#{branch}.#{utc}.benchee", tag: branch],
  formatters: [
    {Benchee.Formatters.HTML, file: "#{report_dir}/index.html", auto_open: false},
    Benchee.Formatters.Console
  ]
)

Benchee.run(%{}, load: "#{save_dir}/*.benchee")
