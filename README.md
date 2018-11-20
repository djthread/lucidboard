# Lb2

A kanban tool.

To start your Phoenix development environment:

```bash
bin/dev.sh
```

The [script's comments](bin/dev.sh) explain a bit more, but you'll get two
docker containers -- a Postgres database (`lb2_dev_db`) and an Elixir
development container (`lb2_dev_app`). The script will then run the fish shell
inside the latter, dropping you into `/app` where the project files reside.

When running this the first time, you'll need to install the dependencies and
initialize the database:

```bash
mix deps.get
cd assets; npm install; cd ..
mix ecto.create
mix ecto.migrate
```

Finally, start the application with `imp`. This is an alias for `iex -S mix
phx.server` which will run the app with Elixir's interactive repl, iex. This
will allow you to test lines of Elixir code and interact with the running
application.

```bash
imp
```

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

To close down and remove the docker containers, run the following script.
Don't worry - all your code and database data (in `assets/db-docker-data`)
will remain intact for next time.

```bash
bin/dev-down.sh
```

## Learn more

  * Official website: http://www.phoenixframework.org/
  * Guides: http://phoenixframework.org/docs/overview
  * Docs: https://hexdocs.pm/phoenix
  * Mailing list: http://groups.google.com/group/phoenix-talk
  * Source: https://github.com/phoenixframework/phoenix
