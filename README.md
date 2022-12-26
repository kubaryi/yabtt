# Yet another BitTorrent Tracker

[![Build](https://github.com/mogeko/yabtt/actions/workflows/build.yml/badge.svg)](https://github.com/mogeko/yabtt/actions/workflows/build.yml)

This is a high-performance BitTorrent Tracker written with [Elixir](https://elixir-lang.org).

> The tracker is an HTTP/HTTPS service which responds to HTTP GET requests. The requests include metrics from clients that help the tracker keep overall statistics about the torrent. The response includes a peer list that helps the client participate in the torrent.

## Usage

> **WARNING**
>
> Not ready for production.

Our philosophy is to make everything as simple as possible. So we chose [SQLite3](https://www.sqlite.org) as the database, which means that you don't need to deploy the database separately.

Moreover, we provide [Docker Container](https://www.docker.com/resources/what-container), which is also our most recommended deployment method:

```shell
docker run -d --name yabtt -p 8080:8080 ghcr.io/mogeko/yabtt
```

Or run with [docker-compose](https://docs.docker.com/compose):

```yml
---
version: 2.1
services:
  yabtt:
    image: ghcr.io/mogeko/yabtt
    container_name: yabtt
    ports:
      - 8080:8080
```

## Configuration

You can configure the server by the `YABTT_*` environment variables (the `-e` option for Docker or the `environment` configuration in `docker-compose.yml`).

Here are the environment variables we support:

| Environment       | Default | Describe                                                                                        |
| ----------------- | ------- | ----------------------------------------------------------------------------------------------- |
| `YABTT_INTERVAL`  | 3600    | Interval in seconds that the client should wait between sending regular requests to the tracker |
| `YABTT_PORT`      | 8080    | The port of server monitoring                                                                   |
| `YABTT_LOG_LEVEL` | `info`  | The [log level](https://hexdocs.pm/logger/Logger.html#module-levels) printed on TTY             |
