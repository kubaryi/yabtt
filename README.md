# Yet another BitTorrent Tracker

[![Build](https://github.com/mogeko/yabtt/actions/workflows/build.yml/badge.svg)](https://github.com/mogeko/yabtt/actions/workflows/build.yml)
[![Version](https://img.shields.io/github/v/tag/mogeko/yabtt?label=Version&logo=docker)](https://github.com/mogeko/yabtt/pkgs/container/yabtt)
[![Powered-by](https://img.shields.io/badge/Powered%20by-Elixir-%234B275F)](https://elixir-lang.org)

This is a **security-first**[^1] and **high-performance**[^2] BitTorrent Tracker.

> The tracker is an HTTP/HTTPS service which responds to HTTP GET requests. The requests include metrics from clients that help the tracker keep overall statistics about the torrent. The response includes a peer list that helps the client participate in the torrent.

Read [our documents](http://mogeko.github.io/yabtt) to learn more.

## Features

1. **Native support for [HTTPS](https://en.wikipedia.org/wiki/HTTPS) and [HSTS](https://www.rfc-editor.org/rfc/rfc6797)**.
2. Supports the HTTP Tracker Protocol ([BEP0003](http://bittorrent.org/beps/bep_0003.html)), but we **don't support or plan** to support the UDP Tracker Protocol ([BEP0015](http://bittorrent.org/beps/bep_0015.html)). -> [_why?_](#why-udp-tracker-protocol-is-not-a-good-idea)
3. Supports both IPv4 and IPv6.
4. Supports the Tracker "Scrape" Extension ([BEP0048](http://bittorrent.org/beps/bep_0048.html)).
5. Supports Compact mode and `no-peer-id` mode ([BEP0023](http://bittorrent.org/beps/bep_0023.html)).

## Usage

> **Warning** **Not ready for production!**

Our philosophy is to make everything as simple as possible. So we chose [SQLite3](https://www.sqlite.org) as the database, which means that you don't need to deploy the database separately.

Moreover, we provide [Docker](https://www.docker.com/resources/what-container) Container, which is also our most recommended deployment method:

> **Note** You should replace `/path/for/certs/` with the location of your [certificates](./guides/setup-https.md#set-up-https).

```shell
docker run -d --name yabtt -v /path/for/certs/:/etc/yabtt/ssl/ -p 8080:8080 ghcr.io/mogeko/yabtt:latest
```

Or run with [Docker Compose](https://docs.docker.com/compose):

```yml
---
version: 2.1

services:
  yabtt:
    image: ghcr.io/mogeko/yabtt:latest
    volumes:
      - /path/for/certs/:/etc/yabtt/ssl/
    container_name: yabtt
    ports:
      - 8080:8080
```

For **HTTPS**, We have prepared a [_more detailed guide_](./guides/setup-https.md).

## Configuration

You can configure the server by the `YABTT_*` environment variables (the `-e` option for Docker or the `environment` configuration in `docker-compose.yml`).

Here are the environment variables we support:

| Environment           | Default | Describe                                                                                                 |
| --------------------- | ------- | -------------------------------------------------------------------------------------------------------- |
| `YABTT_INTERVAL`      | 3600    | Interval in seconds that the client should wait between sending regular requests to the tracker.         |
| `YABTT_PORT`          | 8080    | The port of server monitoring.                                                                           |
| `YABTT_QUERY_LIMIT`   | 50      | Limit the number of peers that the query can return.                                                     |
| `YABTT_COMPACT_ONLY`  | `false` | Force [_compact mode_](https://wiki.theory.org/BitTorrentTrackerExtensions) to save bandwidth. [^3] [^4] |
| `YABTT_DISABLE_HTTPS` | `false` | Set it to `true` to disable HTTPS, **but you should NEVER do this.**                                     |
| `YABTT_LOG_LEVEL`     | `info`  | The [log level](https://hexdocs.pm/logger/Logger.html#module-levels) printed on TTY.                     |

## Examples

See [Examples and Screenshots](http://mogeko.github.io/yabtt/examples-and-screenshots.html)

## Benchmark

For reference, we have designed a simple benchmark to test the main version of the application. However, it should be noted that **the results can only be used as a reference and cannot represent the actual performance of the application in production**.

You can check our report [here](https://github.com/mogeko/yabtt/tree/master/benchmark).

## Why UDP Tracker Protocol is not a good idea?

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

<!-- Comments -->

[^1]: By default, we force HTTPS and run it with ["strict mode"](https://www.rfc-editor.org/rfc/rfc6797).
[^2]: You can check our benchmark [here](https://github.com/mogeko/yabtt/tree/master/benchmark).
[^3]: In the situation that `YABTT_COMPACT_ONLY` be setting by `true`, we will **refuse the request** if the request contains `compact=0`.
[^4]: The compact mode can't work with **IPv6 addresses**. [learn more](https://mogeko.github.io/yabtt/YaBTT.Query.Peers.html#query/2-mode)
