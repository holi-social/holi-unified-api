import express from 'express'
import { Request, Response } from 'express'
import helmet from 'helmet'
import http from 'http'
import { createProxyMiddleware } from 'http-proxy-middleware'
import jwt from 'jsonwebtoken'
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
    console.log('matrix login request:', newBody)
    proxyReq.setHeader('Content-Length', Buffer.byteLength(newBody))
    proxyReq.end(newBody)
  },
  onProxyRes: (proxyRes: http.IncomingMessage, req: Request, res: Response) => {
    console.log('matrix login response:', res)
  },
}

const app = express()

// It is necessary to disable the Content-Security-Policy in the development environments to enable Yoga GraphiQL.
app.use(helmet({ contentSecurityPolicy: process.env.ENVIRONMENT_ID === 'production' }))

app.use('/graphql', createBuiltMeshHTTPHandler())

// add authorization token to login requests
const loginUrl = '/_matrix/client/r0/login'
app.post(loginUrl, express.json()) // this is needed to make the JSON body accessible
app.post(loginUrl, createProxyMiddleware(matrixLoginProxyConfig))

const createJitsiJWT = (userId, userName) => {
  const context = {
    id: `holi_${userId}`,
    email: `${userId}@holi.team`,
    name: userName,
  }
  const claims = {
    context,
    aud: 'jitsi',
    iss: 'jitsi',
    sub: 'holi',
    room: '*',
  }
  return jwt.sign(claims, process.env.JITSI_JWT_SECRET, { expiresIn: '24h' })
}

// add JWT before redirecting to video call for logged in users
app.get('/video-call/:roomName', (req, res) => {
  const roomName = req.params.roomName
  const userId = req.headers['x-holi-user-id']
  const userName = req.headers['x-holi-user-name']

  const jwt = userId && userId !== 'anonymous' && createJitsiJWT(userId, userName)
  const queryParameter = jwt ? `?jwt=${jwt}` : ''
  res.redirect(process.env.VIDEOCALL_URL + '/' + roomName + queryParameter)
})

app.listen(port, () => {
  console.info(`Server listening on port ${port}`)
})
