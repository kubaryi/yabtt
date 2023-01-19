# Yet another BitTorrent Tracker

[![Build](https://github.com/mogeko/yabtt/actions/workflows/build.yml/badge.svg)](https://github.com/mogeko/yabtt/actions/workflows/build.yml)
[![Version](https://img.shields.io/github/v/tag/mogeko/yabtt?label=Version&logo=docker)](https://github.com/mogeko/yabtt/pkgs/container/yabtt)
[![Powered-by](https://img.shields.io/badge/Powered%20by-Elixir-%234B275F)](https://elixir-lang.org)

This is a **security-first**[^1] and **high-performance**[^2] BitTorrent Tracker.

> The tracker is an HTTP/HTTPS service which responds to HTTP GET requests. The requests include metrics from clients that help the tracker keep overall statistics about the torrent. The response includes a peer list that helps the client participate in the torrent.

Read [our documents][documents] to learn more.

## Features

1. **Native support for [HTTPS][https_wiki] and [HSTS][rfc6797]**.
2. Full supports for the HTTP Tracker Protocol in the [BitTorrent protocol specification][bep_0003], but we **don't support or plan to support** the [UDP Tracker Protocol][bep_0015]. -> [_why?_](#why-udp-tracker-protocol-is-not-a-good-idea)
3. Full supports for both IPv4 and IPv6 (including the [Compact mode for IPv6][bep_0007]).
4. Supports the [Tracker "Scrape" Extension][bep_0048].
5. Supports [Compact mode][bep_0023] and provide [`no-peer-id` mode][nopeerid] for compatibility.
6. Tracker statistics via web interface at `/info` or `/stats`. -> [Screenshots][router_info_screenshots]

## Usage

Our philosophy is to make everything as simple as possible. So we chose [SQLite3][sqlite] as the database, which means that you don't need to deploy the database separately.

Moreover, we provide [Docker][docker] Container, which is also our most recommended deployment method:

> **Note** You should replace `/path/for/certs/` with the location of your [certificates][https_certs].

```shell
docker run -d --name yabtt -v /path/for/certs/:/etc/yabtt/ssl/ -p 8080:8080 ghcr.io/mogeko/yabtt:latest
```

Or run with [Docker Compose][docker_compose]:

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

For **HTTPS**, We have prepared a [_more detailed guide_][https_certs].

## Configuration

You can configure the server by the `YABTT_*` environment variables (the `-e` option for Docker or the `environment` configuration in `docker-compose.yml`).

Here are the environment variables we support:

| Environment           | Default | Describe                                                                                         |
| --------------------- | ------- | ------------------------------------------------------------------------------------------------ |
| `YABTT_INTERVAL`      | 3600    | Interval in seconds that the client should wait between sending regular requests to the tracker. |
| `YABTT_PORT`          | 8080    | The port of server monitoring.                                                                   |
| `YABTT_QUERY_LIMIT`   | 50      | Limit the number of peers that the query can return.                                             |
| `YABTT_COMPACT_ONLY`  | `false` | Force [_compact mode_][bep_0023] to save bandwidth. [^3]                                         |
| `YABTT_DISABLE_HTTPS` | `false` | Set it to `true` to disable HTTPS, **but you should NEVER do this.**                             |
| `YABTT_LOG_LEVEL`     | `info`  | The [log level][log_level] printed on TTY.                                                       |

## Examples

See [Examples and Screenshots][examples].

## Benchmark

For reference, we have designed a simple benchmark to test the main version of the application. However, it should be noted that **the results can only be used as a reference and cannot represent the actual performance of the application in production**.

You can check our report [here][benchmark].

## Why UDP Tracker Protocol is not a good idea?

[UDP Tracker Protocol][bep_0015] allows clients to use UDP, which is lighter than TCP, to reducing the complexity of tracker code and increasing it's performance.

However, there is a **fatal defect** for UDP. **UDP is more difficult to encrypt than HTTP!** Although there is an idea like [DoT (DNS Over TLS)][rfc7858], it is difficult to be popular, not to mention that DoT also has the disadvantage that [the traffic characteristics are too obvious][limit_for_dot]. Its successor, [DoH (DNS Over HTTPS)][rfc8484], sends HTTP traffic! As a BitTorrent Tracker Server with "security"[^1] as the selling point, we can't stand such a "dangerous" transmission protocol such as UDP!

On the other hand, UDP is not a **silver bullet** to solve performance problems! **I don't even think it's the right idea to use a transport layer protocol to solve an application layer problem.** In order to solve performance problems, we should focus more on solutions such as [HTTP/2][rfc7540] or [HTTP/3][rfc9114] than on "evil ways" like UDP.

## Build

See [Compilation Guide][build_guide]

## Reference

This project refers to the following documents or specifications.

- [BitTorrent Enhancement Proposals](http://bittorrent.org/beps/bep_0000.html)
- [Bittorrent Protocol Specification v1.0](https://wiki.theory.org/BitTorrentSpecification)
- [BitTorrent Wish List](https://wiki.theory.org/BitTorrentWishList)
- [BitTorrent Tracker Protocol Extensions](https://wiki.theory.org/BitTorrentTrackerExtensions)

## License

The code in this project is released under the [GPL-3.0 License](./LICENSE).

<!-- links -->

[sqlite]: https://www.sqlite.org
[docker]: https://www.docker.com/resources/what-container
[docker_compose]: https://docs.docker.com/compose
[log_level]: https://hexdocs.pm/logger/Logger.html#module-levels
[https_wiki]: https://en.wikipedia.org/wiki/HTTPS
[limit_for_dot]: https://www.cloudflare.com/learning/dns/dns-over-tls
[nopeerid]: https://wiki.theory.org/BitTorrentTrackerExtensions

<!-- documents -->

[documents]: http://mogeko.github.io/yabtt
[examples]: https://mogeko.github.io/yabtt/examples-and-screenshots.html
[router_info_screenshots]: https://mogeko.github.io/yabtt/examples-and-screenshots.html#call-info-or-stats
[limit_for_compact_mode]: https://mogeko.github.io/yabtt/YaBTT.Query.Peers.html#query/2-mode
[https_certs]: ./guides/setup-https.md#set-up-https
[benchmark]: ./benchmark/README.md
[build_guide]: ./guides/compilation-guide.md

<!-- BitTorrent Enhancement Proposals -->

[bep_0003]: http://bittorrent.org/beps/bep_0003.html
[bep_0007]: http://bittorrent.org/beps/bep_0007.html
[bep_0015]: http://bittorrent.org/beps/bep_0015.html
[bep_0023]: http://bittorrent.org/beps/bep_0023.html
[bep_0048]: http://bittorrent.org/beps/bep_0048.html

<!-- Request for Comments -->

[rfc6797]: https://www.rfc-editor.org/rfc/rfc6797
[rfc7858]: https://www.rfc-editor.org/rfc/rfc7858
[rfc8484]: https://www.rfc-editor.org/rfc/rfc8484
[rfc7540]: https://www.rfc-editor.org/rfc/rfc7540
[rfc9114]: https://www.rfc-editor.org/rfc/rfc9114

<!-- Comments -->

[^1]: By default, we force HTTPS and run it with ["strict mode"][rfc6797].
[^2]: You can check our benchmark report [here][benchmark].
[^3]: In the situation that `YABTT_COMPACT_ONLY` be setting by `true`, we will **refuse the request** if the request contains `compact=0`.
