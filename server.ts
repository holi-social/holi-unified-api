import express from 'express'

import { createBuiltMeshHTTPHandler } from './.mesh'
import { createProxyMiddleware } from 'http-proxy-middleware'

const asNumber = (str?: string) => (str ? Number(str) : undefined)

const port = asNumber(process.env.PORT) || 4000
const matrixServerUrl = process.env.MATRIX_SERVER_BASE_URL || 'http://127.0.0.1:8008/'

console.debug(`Server starting on port ${port}`)

const chatLoginProxy = (matrixServerUrl: string) => {
  const parseJwt = (token: string) => {
    return JSON.parse(Buffer.from(token.split('.')[1], 'base64').toString())
  }
  return createProxyMiddleware({
    target: matrixServerUrl,
    changeOrigin: true,
    onProxyReq: (proxyReq, req) => {
      const oldBody = req.body.json()
      if (!oldBody) return
      console.log('Old Body:', oldBody)

      // TODO - This is a hack to get the token from the authorization header
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
}

const app = express()

app.use('/graphql', createBuiltMeshHTTPHandler())
app.use('/_matrix/client/r0/login', chatLoginProxy(matrixServerUrl))

console.debug(`Server starting on port ${port}`)

app.listen(4000, () => {
  console.info(`Server listening on port ${port}`)
})
