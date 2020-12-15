# Butler

## Get started

### Production

```sh
docker build -t butler .
docker run -e DATABASE_URL=<REPLACE_WITH_DB_URL> -e SECRET_KEY_BASE=<REPLACE_WITH_SECRET_KEY> butler:latest
```

You could test if the container builds by running PostgreSQL, and setting
`DATABASE_URL=DATABASE_URL=postgres://postgres:postgres@db:5432/<REPLACE_DB_NAME>`

To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.setup`
  * Install Node.js dependencies with `npm install` inside the `assets` directory
  * Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## Learn more

  * Official website: https://www.phoenixframework.org/
  * Guides: https://hexdocs.pm/phoenix/overview.html
  * Docs: https://hexdocs.pm/phoenix
  * Forum: https://elixirforum.com/c/phoenix-forum
  * Source: https://github.com/phoenixframework/phoenix
