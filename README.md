![Continuous Integration](https://github.com/pedroperrone/listify/workflows/Continuous%20Integration/badge.svg)

# Listify

This repository contains the implementation of a simple shopping list. It has both a UI built with LiveView and a REST API.

## Dependencies

To run the project and its tests, the following dependencies are required:
* Elixir 1.10
* Postgres 11+

## Running the project

To run the project, first export the following environment variables regarding your database configuration:
* `DATABASE_USERNAME` - Defaults to `postgres`
* `DATABASE_PASSWORD` - Defaults to `postgres`
* `DATABASE_NAME` - Defaults to `listify_dev`
* `DATABASE_POOL_SIZE` - Defaults to `10`

Then, navigate to the cloned repository and run the following commands:
```shell
mix deps.get
mix ecto.setup
mix phx.server
```

The project will be available on `localhost:4000`. The list is under the route `/items`.

## Running unit tests

The library used to build unit tests was `ExUnit`. In assistance to it, `ExMachina` was used to build factories.

To run the tests, first export the database credentials and name (here the default name changed to `listify_test`) and then use the command `mix test`.

## Static code analysis

Two tools were set in the project: `Credo`, which is focused on code consistency and refactor opportunities, and `Dialyzer`, which is focused on identifying software discrepancies, such as definite type errors, code that has become dead or unreachable because of programming error. To run them, use the commands
```shell
mix credo
mix dialyzer
```

## Architecture

In order to avoid code duplication in the full stack application and in the API, the concept of [use cases](http://www.plainionist.net/Implementing-Clean-Architecture-UseCases/) was implemented. The use cases are the intermediate between the business rules and the presenters, which are the controllers and the LiveView modules.
