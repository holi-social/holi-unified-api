# holi-unified-api

This project contains our GraphQL unified API that provides all backend APIs to the frontends.

## Authentication and Mesh

This project consists of mainly two parts in a single docker container. The docker container validates authentication
using Ory's [Zero Trust Proxy](https://www.ory.sh/docs/oathkeeper), and provides access to backend APIs in a single
GraphQL endpoint using [GraphQL Mesh](https://www.graphql-mesh.com/).

## Running in development

Please take a look at the `holi-meta` project for running this component locally.

## CI/CD

The CI/CD pipeline follows our normal flow, deploying branch environments and deploying main to staging automatically
and to production manually after e2e tests.
