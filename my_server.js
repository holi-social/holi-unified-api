const express = require('express')
const { createProxyMiddleware } = require('http-proxy-middleware')
const bodyParser = require('body-parser')
const { createYoga } = require('graphql-yoga')

const app = express()

const yoga = createYoga()

// Bind GraphQL Yoga to the graphql endpoint to avoid rendering the playground on any path
app.use(yoga.graphqlEndpoint, yoga)

const parseJwt = (token) => {
  return JSON.parse(Buffer.from(token.split('.')[1], 'base64').toString())
}

const targetHost = 'http://127.0.0.1:8008/'
const loginUrl = '/_matrix/client/r0/login'
// add authorization token to login requets
app.post(loginUrl, bodyParser.json())
app.post(
  loginUrl,
  createProxyMiddleware({
    target: targetHost,
    changeOrigin: true,
    onProxyReq: (proxyReq, req) => {
      const oldBody = req.body
      if (!oldBody) return
      console.log('Old Body:', oldBody)

      const jwt = req.get('authorization')
      if (!oldBody.token && jwt && jwt.startsWith('Bearer ')) {
        oldBody.token = jwt.slice(7)
        console.log('Token:', parseJwt(oldBody.token))
      }
      const newBody = JSON.stringify(oldBody)
      console.log('New Body:', newBody)
      proxyReq.setHeader('Content-Length', Buffer.byteLength(newBody))
      proxyReq.end(newBody)
    },
  })
)

app.listen(4000, () => {
  console.log('Running a GraphQL API server at http://localhost:4000/graphql')
})
