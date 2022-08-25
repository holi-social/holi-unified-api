# holi-unified-api

This project contains our GraphQL unified API that provides all backend APIs to the frontends.

## Authentication and Mesh

This project consists of mainly two parts in a single docker container. The docker container validates authentication
using Ory's [Zero Trust Proxy](https://www.ory.sh/docs/oathkeeper), and provides access to backend APIs in a single
GraphQL endpoint using [GraphQL Mesh](https://www.graphql-mesh.com/).

## Running in development

Please take a look at the `holi-meta` project for running this component locally.

### Prerequisites

Run `cp .envrc.local.template .envrc.local` and adjust `.envrc.local` to match your configuration (e.g. using the correct node version manager). Using `direnv`, `.envrc` (and `.envrc.local`) will automatically be loaded when you `cd` into the directory.

`.node-version` (used by `nodenv`) ensures that all developers are using the same `node`/`npm` versions.
It is kept in sync with `.nvmrc` (used by `nvm`) by a symbolic link, so please make sure to use a format that is understood by both tools (e.g. a fixed version).

## CI/CD

The CI/CD pipeline follows our normal flow, deploying branch environments and deploying main to staging automatically
and to production manually. The e2e tests that should go in between staging and prod deployments are missing up until now.
