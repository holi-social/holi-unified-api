import { createHmac } from 'crypto'
import express, { Request } from 'express'
import helmet from 'helmet'
import http from 'http'
import { createProxyMiddleware } from 'http-proxy-middleware'
import jwt from 'jsonwebtoken'
import { exit } from 'process'

import { createBuiltMeshHTTPHandler } from './.mesh'
import { setupNotificationWebhook } from './handlers/notificationWebhook'

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

// It is necessary to disable the Content-Security-Policy in the development environments to enable Yoga GraphiQL.
app.use(helmet({ contentSecurityPolicy: process.env.ENVIRONMENT_ID === 'production' }))

app.use('/graphql', createBuiltMeshHTTPHandler())

// add authorization token to login requests
const loginUrl = '/_matrix/client/r0/login'
app.post(loginUrl, express.json()) // this is needed to make the JSON body accessible
app.post(loginUrl, createProxyMiddleware(loginUrl, matrixLoginProxyConfig))

const oryWebhookUrl = '/ory-webhook'
app.post(
  oryWebhookUrl,
  createProxyMiddleware(oryWebhookUrl, {
    target: process.env.OKUNA_DOMAIN,
    changeOrigin: true,
  })
)

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

app.get('/api/novu/credentials', async (req, res) => {
  const userId = req.headers['x-holi-user-id']
  if (!userId || Array.isArray(userId)) {
    res.status(401).send('Unauthorized')
    return
  }

  try {
    const usersHmacHash = createHmac('sha256', process.env.NOVU_API_KEY).update(userId).digest('hex')
    res.status(200).send({ hmacHash: usersHmacHash })
  } catch (e) {
    res.status(400).send("Couldn't generate the users credentials.")
  }
})

setupNotificationWebhook(app, '/notification-webhook')

app.listen(port, () => {
  console.info(`Server listening on port ${port}`)
})
