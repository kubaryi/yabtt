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

COPY . .

# Install dependencies and build release
RUN mix do deps.get, deps.compile, compile, release


# ==== Runtime ====
FROM alpine:${ALPINE_VERSION} AS app

# Set the locale to UTF-8
ENV LANG=C.UTF-8

WORKDIR /app

# Install dependencies for Erlang and Elixir
RUN apk add --no-cache openssl libgcc libstdc++ ncurses-libs

# Copy the release from the builder
COPY --from=builder /app/_build/prod/rel/yabtt .

# Run the application
ENTRYPOINT ["/app/bin/yabtt"]
CMD ["start"]
