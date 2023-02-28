ARG DEBIAN_VERSION=stable-slim
ARG ELIXIR_VERSION=1.14.2-slim

# ==== Builder ====
FROM elixir:${ELIXIR_VERSION} AS builder

# The environment to build with
ARG MIX_ENV=prod
ENV MIX_ENV=${MIX_ENV}

WORKDIR /app

# Setup hex and rebar
RUN mix local.hex --force && \
    mix local.rebar --force

# Install dependencies for build sqlite3
RUN apt update && apt install -y build-essential

COPY . .

# Install & compile the dependencies of Elixir
RUN mix deps.get --only ${MIX_ENV} && \
    mix deps.compile --force

# Create and migrate the database
RUN mix do ecto.create, ecto.migrate
# Compile the application
RUN mix do compile, release


# ==== Runtime ====
FROM debian:${DEBIAN_VERSION} AS app

# Metadata
LABEL org.opencontainers.image.title         yabtt
LABEL org.opencontainers.image.source        https://github.com/kubaryi/yabtt
LABEL org.opencontainers.image.url           https://github.com/kubaryi/yabtt
LABEL org.opencontainers.image.documentation https://kubaryi.github.io/yabtt
LABEL org.opencontainers.image.authors       kubaryi
LABEL org.opencontainers.image.description   Yet Another BitTorrent Tracker
LABEL org.opencontainers.image.licenses      GPL-3.0

# Set the locale to UTF-8
ENV LANG=C.UTF-8

WORKDIR /app

# Copy the release from the builder
COPY --from=builder /app/_build/prod/rel/yabtt .
COPY --from=builder /var/lib/sqlite3 /var/lib/sqlite3

EXPOSE 8080 8080/udp

# Run the application
ENTRYPOINT ["/app/bin/yabtt"]
CMD ["start"]
