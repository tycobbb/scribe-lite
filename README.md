# Scribe

## Table of Contents

- [Setup](#setup-)
- [Development](#development-)

## Setup [↑](#table-of-contents)

Install any necessary global dependencies. Some packages may need to be installed using the package manager(s) appropriate for your system:

- yarn -> [installation](https://yarnpkg.com/en/docs/install)
- elixir -> `brew install elixir`
- elm -> `brew install elm`
- elm-install -> `yarn global elm-github-install`

Then install local dependencies:

```sh
$ mix deps.get
$ yarn
$ elm-install
```

## Development [↑](#table-of-contents)

Make sure your database is created and migrated:

```sh
$ mix ecto.create && mix ecto.migrate
```

Then start the Phoenix server to serve the app on http://localhost:4000:

```sh
$ mix phoenix.server
```
