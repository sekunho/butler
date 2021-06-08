# Butler

Declare your free time during the week

![image](https://user-images.githubusercontent.com/20364796/121242878-95416680-c88c-11eb-97b5-3e4d4aefdc23.png)

and Butler takes care of the things you have to do based on priority.

![image](https://user-images.githubusercontent.com/20364796/121242910-9d99a180-c88c-11eb-8575-83487bec43b3.png)

## Get started

### Dev (WIP)

### Production (WIP)

```sh
docker build -t butler .
docker run -e DATABASE_URL=<REPLACE_WITH_DB_URL> -e SECRET_KEY_BASE=<REPLACE_WITH_SECRET_KEY> butler:latest
```

You could test if the container builds by running PostgreSQL, and setting
`DATABASE_URL=postgres://postgres:postgres@db:5432/<REPLACE_DB_NAME>`

To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.setup`
  * Install Node.js dependencies with `npm install` inside the `assets` directory
  * Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.
