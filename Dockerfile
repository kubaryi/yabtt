ARG ALPINE_VERSION=3.16
ARG ELIXIR_VERSION=1.14

# ==== Builder ====
FROM elixir:${ELIXIR_VERSION}-alpine AS builder

# The environment to build with
ARG MIX_ENV=prod
ENV MIX_ENV=${MIX_ENV}

WORKDIR /app

# Install build dependencies
RUN apk add --no-cache build-base

# Setup hex and rebar
RUN mix local.hex --force && \
    mix local.rebar --force

COPY . .

# Install elixir dependencies
RUN mix do deps.get, deps.compile

# Create and migrate the database
RUN mix do ecto.create, ecto.migrate
# Compile the application
RUN mix do compile, release


# ==== Runtime ====
FROM alpine:${ALPINE_VERSION} AS app

# Set the locale to UTF-8
ENV LANG=C.UTF-8

WORKDIR /app

# Install dependencies for Erlang and Elixir
RUN apk add --no-cache openssl libstdc++ ncurses-libs

# Copy the release from the builder
COPY --from=builder /app/_build/prod/rel/yabtt .
COPY --from=builder /var/lib/sqlite3 /var/lib/sqlite3

EXPOSE 8080 8080/udp

# Run the application
ENTRYPOINT ["/app/bin/yabtt"]
CMD ["start"]
