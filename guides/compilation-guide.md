# Compilation Guide

If you want to compile the application yourself, you can follow this guide.

## Download the source code

First of all, you need to download the source code by [Git](https://git-scm.com):

```shell
git clone https://github.com/kubaryi/yabtt.git
```

Then enter the working directory `./yabtt`.

## By Docker Container

This is the easiest way to compile software.

You just need the following commands (**Don't forget the `.`**):

```shell
docker build --build-arg MIX_ENV=prod -t yabtt:latest .
```

Then the Docker will take care of everything for us.

### Build containers based on `alpine`

Since [`0.1.1-r1`](https://github.com/kubaryi/yabtt/tree/18ee9f3986ea63db2b870da84d0aa150ac96e80d), we have used [`debian:stable-slim`](https://hub.docker.com/_/debian) as the basic container by default for better compatibility reasons. But it has to be admitted that the containers based on [`alpine`](https://hub.docker.com/_/alpine) will have an unparalleled <sub>size</sub> advantage.

```plaintext
REPOSITORY             TAG               IMAGE ID       CREATED              SIZE
yabtt                  debian-slim       578a12c2757e   ...                  148MB
yabtt                  alpine            749a8378d467   ...                  26.1MB
```

If you need this nearly 100MB space for hard disk, you can refer to the following file to customize `./Dockerfile`:

```dockerfile
ARG ALPINE_VERSION=3.16
ARG ELIXIR_VERSION=1.14

# ==== Builder ====
FROM elixir:${ELIXIR_VERSION}-alpine AS builder

# The environment to build with
ARG MIX_ENV=prod
ENV MIX_ENV=${MIX_ENV}

WORKDIR /app

# Setup hex and rebar
RUN mix local.hex --force && \
    mix local.rebar --force

# Install dependencies for build sqlite3
RUN apk add --no-cache build-base

COPY . .

# Install & compile the dependencies of Elixir
RUN mix deps.get --only ${MIX_ENV} && \
    mix deps.compile --force

# Create and migrate the database
RUN mix do ecto.create, ecto.migrate
# Compile the application
RUN mix do compile, release


# ==== Runtime ====
FROM alpine:${ALPINE_VERSION} AS app

# Set the locale to UTF-8
ENV LANG=C.UTF-8

WORKDIR /app

# Install dependencies for BEAM
RUN apk add --no-cache openssl libstdc++ ncurses-libs

# Copy the release from the builder
COPY --from=builder /app/_build/prod/rel/yabtt .
COPY --from=builder /var/lib/sqlite3 /var/lib/sqlite3

EXPOSE 8080 8080/udp

# Run the application
ENTRYPOINT ["/app/bin/yabtt"]
CMD ["start"]
```

## By Elixir

If you don't like Docker, you can also compile it manually after [installing Elixir](https://elixir-lang.org/install.html).

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
