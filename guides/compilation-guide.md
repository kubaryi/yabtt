# Compilation Guide

If you want to compile the application yourself, you can follow this guide.

## Download the source code

First of all, you need to download the source code by [Git](https://git-scm.com):

```shell
git clone https://github.com/mogeko/yabtt.git
```

Then enter the working directory `./yabtt`.

## By Docker Container

This is the easiest way to compile software.

You just need the following commands (**Don't forget the `.`**):

```shell
docker build --build-arg MIX_ENV=prod -t yabtt:latest .
```

Then the Docker will take care of everything for us.

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
