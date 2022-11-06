ARG DEBIAN_VERSION=stable-slim
ARG ELIXIR_VERSION=slim

# ==== Builder ====
FROM elixir:${ELIXIR_VERSION} AS builder

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
FROM debian:${DEBIAN_VERSION} AS app

# Set the locale to UTF-8
ENV LANG=C.UTF-8

WORKDIR /app

# Copy the release from the builder
COPY --from=builder /app/_build/prod/rel/yabtt .

# Run the application
ENTRYPOINT ["/app/bin/yabtt"]
CMD ["start"]
