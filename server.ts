import express from 'express'
import { Request } from 'express'
import http from 'http'
import { createProxyMiddleware } from 'http-proxy-middleware'
import { exit } from 'process'

import { createBuiltMeshHTTPHandler } from './.mesh'

const asNumber = (str?: string) => (str ? Number(str) : undefined)

const port = asNumber(process.env.GRAPHQL_PORT) || 4000
const matrixServerUrl = process.env.MATRIX_SERVER_BASE_URL
if (!matrixServerUrl) {
  console.error('Environment variable MATRIX_SERVER_BASE_URL is not specified. Exiting.')
  exit(1)
}

console.debug(`Server starting on port ${port}`)

const matrixLoginProxyConfig = {
  target: matrixServerUrl,
  changeOrigin: true,
  onProxyReq: (proxyReq: http.ClientRequest, req: Request) => {
    const oldBody = req.body
    if (!oldBody) return

    // TODO - This is a hack to get the token from the authorization header
    const jwt = req.get('authorization')
    if (!oldBody.token && jwt && jwt.startsWith('Bearer ')) {
      oldBody.token = jwt.slice(7)
    }
    const newBody = JSON.stringify(oldBody)
    proxyReq.setHeader('Content-Length', Buffer.byteLength(newBody))
    proxyReq.end(newBody)
  },
}

const app = express()

app.use('/graphql', createBuiltMeshHTTPHandler())

// add authorization token to login requets
const loginUrl = '/_matrix/client/r0/login'
app.post(loginUrl, express.json()) // this is needed to make the JSON body accessible
app.post(loginUrl, createProxyMiddleware(matrixLoginProxyConfig))

app.listen(port, () => {
  console.info(`Server listening on port ${port}`)
})
