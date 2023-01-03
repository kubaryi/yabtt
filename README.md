# Yet another BitTorrent Tracker

[![Build](https://github.com/mogeko/yabtt/actions/workflows/build.yml/badge.svg)](https://github.com/mogeko/yabtt/actions/workflows/build.yml)

This is a high-performance BitTorrent Tracker written with [Elixir](https://elixir-lang.org).

> The tracker is an HTTP/HTTPS service which responds to HTTP GET requests. The requests include metrics from clients that help the tracker keep overall statistics about the torrent. The response includes a peer list that helps the client participate in the torrent.

Read [our documents](http://mogeko.github.io/yabtt) to learn more.

## Usage

> **Warning** **Not ready for production!**

Our philosophy is to make everything as simple as possible. So we chose [SQLite3](https://www.sqlite.org) as the database, which means that you don't need to deploy the database separately.

Moreover, we provide [Docker](https://www.docker.com/resources/what-container) Container, which is also our most recommended deployment method:

> **Warning**
>
> We used `YABTT_DISABLE_HTTPS=true` here to disable HTTPS, **but you should NEVER do this in your production environment!**

```shell
docker run -d --name yabtt -e YABTT_DISABLE_HTTPS=true -p 8080:8080 ghcr.io/mogeko/yabtt:latest
```

Or run with [Docker Compose](https://docs.docker.com/compose):

```yml
---
version: 2.1
services:
  yabtt:
    image: ghcr.io/mogeko/yabtt:latest
    environment:
      - YABTT_DISABLE_HTTPS=true
    container_name: yabtt
    ports:
      - 8080:8080
```

## Configuration

You can configure the server by the `YABTT_*` environment variables (the `-e` option for Docker or the `environment` configuration in `docker-compose.yml`).

Here are the environment variables we support:

| Environment           | Default | Describe                                                                                         |
| --------------------- | ------- | ------------------------------------------------------------------------------------------------ |
| `YABTT_INTERVAL`      | 3600    | Interval in seconds that the client should wait between sending regular requests to the tracker. |
| `YABTT_PORT`          | 8080    | The port of server monitoring.                                                                   |
| `YABTT_QUERY_LIMIT`   | 50      | Limit the number of peers that the query can return.                                             |
| `YABTT_COMPACT_ONLY`  | `false` | Forces the use of ["compact mode"](https://wiki.theory.org/BitTorrentTrackerExtensions)          |
| `YABTT_DISABLE_HTTPS` | `false` | Set it to `true` to disable HTTPS, **but you should NOT to do this.**                            |
| `YABTT_LOG_LEVEL`     | `info`  | The [log level](https://hexdocs.pm/logger/Logger.html#module-levels) printed on TTY.             |

> **Warning**
>
> In the situation than `YABTT_COMPACT_ONLY` be setting by `true`, we will **refuse the request** if the request contains `compact=0`. At the same time, it should be noted that the "compact mode" can't work with **IPv6 addresses**. If the IP address of the peer is an IPv6 address, we will ignore those peer.
>
> You can find more information in [our document](https://mogeko.github.io/yabtt/YaBTT.Query.Peers.html#query/2-mode).

## Examples

See [Examples and Screenshots](http://mogeko.github.io/yabtt/examples-and-screenshots.html)

## Benchmark

For reference, we have designed a simple benchmark to test the main version of the application. However, it should be noted that **the results can only be used as a reference and cannot represent the actual performance of the application in production**.

You can check our report [here](https://github.com/mogeko/yabtt/tree/master/benchmark).

## Build

See [Compilation Guide](./guides/compilation-guide.md)

## Reference

This project refers to the following documents or specifications.

- [BitTorrent Enhancement Proposals](http://bittorrent.org/beps/bep_0000.html)
- [Bittorrent Protocol Specification v1.0](https://wiki.theory.org/BitTorrentSpecification)
- [BitTorrent Wish List](https://wiki.theory.org/BitTorrentWishList)
- [BitTorrent Tracker Protocol Extensions](https://wiki.theory.org/BitTorrentTrackerExtensions)

## License

The code in this project is released under the [GPL-3.0 License](./LICENSE).
