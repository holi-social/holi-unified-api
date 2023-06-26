import express from 'express'
import { createYoga } from 'graphql-yoga'

console.log('======== SERVER STARTING ========')

const app = express()

const yoga = createYoga()

// Bind GraphQL Yoga to the graphql endpoint to avoid rendering the playground on any path
app.use(yoga.graphqlEndpoint, yoga)

app.listen(4000, () => {
  console.info('Server is listening on Port 4000')
})

// const server = createServer(createBuiltMeshHTTPHandler())
// server.listen(4000)
