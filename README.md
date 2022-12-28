# Yet another BitTorrent Tracker

[![Build](https://github.com/mogeko/yabtt/actions/workflows/build.yml/badge.svg)](https://github.com/mogeko/yabtt/actions/workflows/build.yml)

This is a high-performance BitTorrent Tracker written with [Elixir](https://elixir-lang.org).

> The tracker is an HTTP/HTTPS service which responds to HTTP GET requests. The requests include metrics from clients that help the tracker keep overall statistics about the torrent. The response includes a peer list that helps the client participate in the torrent.

Read [our documents](http://mogeko.github.io/yabtt) to learn more.

## Usage

> **Warning** **Not ready for production!**

Our philosophy is to make everything as simple as possible. So we chose [SQLite3](https://www.sqlite.org) as the database, which means that you don't need to deploy the database separately.

Moreover, we provide [Docker](https://www.docker.com/resources/what-container) Container, which is also our most recommended deployment method:

```shell
docker run -d --name yabtt -p 8080:8080 ghcr.io/mogeko/yabtt:latest
```

Or run with [Docker Compose](https://docs.docker.com/compose):

```yml
---
version: 2.1
services:
  yabtt:
    image: ghcr.io/mogeko/yabtt:latest
    container_name: yabtt
    ports:
      - 8080:8080
```

## Configuration

You can configure the server by the `YABTT_*` environment variables (the `-e` option for Docker or the `environment` configuration in `docker-compose.yml`).

Here are the environment variables we support:

| Environment          | Default | Describe                                                                                         |
| -------------------- | ------- | ------------------------------------------------------------------------------------------------ |
| `YABTT_INTERVAL`     | 3600    | Interval in seconds that the client should wait between sending regular requests to the tracker. |
| `YABTT_PORT`         | 8080    | The port of server monitoring.                                                                   |
| `YABTT_QUERY_LIMIT`  | 50      | Limit the number of peers that the query can return.                                             |
| `YABTT_LOG_LEVEL`    | `info`  | The [log level](https://hexdocs.pm/logger/Logger.html#module-levels) printed on TTY.             |
| `YABTT_COMPACT_ONLY` | `false` | Forces the use of ["compact mode"](https://wiki.theory.org/BitTorrentTrackerExtensions)          |

> **Warning**
>
> In the situation than `YABTT_COMPACT_ONLY` be setting by `true`, we will **refuse the request** if the request contains `compact=0`. At the same time, it should be noted that the "compact mode" can't work with **IPv6 addresses**. If the IP address of the peer is an IPv6 address, we will degenerate to "no_peer_id mode" or "full peer info mode" according to actual situation.
>
> You can find more information in [our document](https://mogeko.github.io/yabtt/YaBTT.Response.html#extract/2-options).

## Benchmark

For reference, we have designed a simple benchmark to test the main version of the application. However, it should be noted that **the results can only be used as a reference and cannot represent the actual performance of the application in production**.

You can check our report [here](https://github.com/mogeko/yabtt/tree/master/benchmark).

## Build

If you want to compile it yourself, you can follow this guide.

First of all, you need to download the source code by [Git](https://git-scm.com):

```shell
git clone https://github.com/mogeko/yabtt.git
```

Then enter the working directory `./yabtt`.

### Docker Container

This is the easiest way to compile software.

You just need the following commands (**Don't forget the `.`**):

```shell
docker build --build-arg MIX_ENV=prod -t yabtt:latest .
```

Then the Docker will take care of everything for us.

### Elixir

If you don't like Docker, you can also compile it manually after installing Elixir.

First of all, we need to install [Hex](https://hex.pm), which is Elixir's official package repository (similar to NPM for Node.js).

```shell
mix local.hex
```

Then, install all dependencies required for compilation.

> **Note** In order to compile `sqlite3.c`, the [`make`](https://www.gnu.org/software/make) and the [`C` Environment](https://gcc.gnu.org) are required.

```shell
MIX_ENV=prod mix do deps.get, deps.compile
```

Then create and initialize the database.

> **Note**
>
> The default location of the database file is: `/var/lib/sqlite3/yabtt.db`
>
> You can configure it in the `./config/config.exs`:
>
> ```elixir
> if config_env() == :prod do
>   config :yabtt, YaBTT.Repo, database: "/the/path/you/want.db"
> end
> ```

```shell
MIX_ENV=prod mix do ecto.create, ecto.migrate
```

Finally, compile and package the software.

```shell
MIX_ENV=prod mix do compile, release
```

The compiled files are located in the folder `_build/prod/rel/yabtt/`.

## Reference

This project refers to the following documents or specifications.

- [BitTorrent Enhancement Proposals](http://bittorrent.org/beps/bep_0000.html)
- [Bittorrent Protocol Specification v1.0](https://wiki.theory.org/BitTorrentSpecification)
- [BitTorrent Wish List](https://wiki.theory.org/BitTorrentWishList)
- [BitTorrent Tracker Protocol Extensions](https://wiki.theory.org/BitTorrentTrackerExtensions)

## License

The code in this project is released under the [GPL-3.0 License](./LICENSE).
