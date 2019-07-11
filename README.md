# Lucidboard

A realtime, collaborative kanban tool, built on
[Elixir](https://elixir-lang.org/), [Phoenix](https://phoenixframework.org/),
and
[LiveView](https://dockyard.com/blog/2018/12/12/phoenix-liveview-interactive-real-time-apps-no-need-to-write-javascript).

**Status:** We've met our MVP goals! Now we're just adding features. As always,
pull requests welcome!

**CI:** [Lucidboard on CircleCI](https://circleci.com/gh/djthread/lucidboard) [![CircleCI](https://circleci.com/gh/djthread/lucidboard.svg?style=svg)](https://circleci.com/gh/djthread/lucidboard)

To start your Phoenix development environment:

```bash
bin/dev
```

**Note:** If you are on the Quicken Loans network, you'll want to invoke this
script with `bin/dev --ql` or you will get errors around HTTPS authentication.

The [script's comments](bin/dev) explain a bit more, but you'll get two
docker containers -- a Postgres database (`lucidboard_dev_db`) and an Elixir
development container (`lucidboard_dev_app`). The script will then run the
fish shell inside the latter, dropping you into `/app` where the project
files reside.

When running this the first time, you'll need to install the dependencies and
initialize the database. (You may also simply type `setup` since it is an alias
for these commands.)

```bash
mix deps.get
cd assets; npm install; cd ..
mix ecto.setup
```

Finally, start the application with `imp`. This is an alias for `iex -S mix
phx.server` which will run the app with Elixir's interactive repl, iex. This
will allow you to test lines of Elixir code and interact with the running
application. `imp` is the only command you'll need next time, now that things
are installed.

```bash
imp
```

Now you can visit [`localhost:8800`](http://localhost:8800) from your browser.

To close down and remove the docker containers, run the following script.
Don't worry - all your code and database data will remain intact for next
time.

```bash
bin/down
```

## Shell Aliases

These [recommended few](assets/ops/config.fish) aliases are imported to the
fish shell in the docker-based dev environment.

| Alias   | Full Command          |
| ------- | --------------------- |
| `imp`   | iex -S mix phx.server |
| `im`    | iex -S mix            |
| `mdg`   | iex mix deps.get      |
| `mdu`   | mix deps.update --all |
| `mt`    | mix test              |
| `mtw`   | mix test.watch        |
| `ml`    | mix lint              |
| `mer`   | mix ecto.reset        |
| `setup` | mix deps.get<br>cd assets; npm install; cd ..<br> mix ecto.setup | 

## License

Per the included [`LICENSE.txt`](LICENSE.txt), Lucidboard is made available
under the MIT license.