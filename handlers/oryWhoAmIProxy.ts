import type { NextFunction, Request, Express, RequestHandler } from 'express'
import { createProxyMiddleware } from 'http-proxy-middleware'
import cookieParser from 'cookie-parser'
import NodeCache from 'node-cache'
import { asNumber, ensureEnv } from './../utils'

const oryWhoamiUrl = ensureEnv('ORY_WHOAMI_URL')
const orySessionKey = ensureEnv('ORY_SESSION_KEY')
const TTL = asNumber(process.env.ORY_TTL_SECONDS) || 2

const cache = new NodeCache({ stdTTL: TTL })

const cacheOry: RequestHandler = (req: Request, res: any, next: NextFunction) => {
  const cookie = req.cookies[orySessionKey]
  const cached = cache.get(cookie)
  if (cached) {
    return res.json(cached)
  }
  next()
}

export const setupOryWhoAmI = (app: Express) => {
  app.use(cookieParser())

  app.use(
    '/orywhoami',
    cacheOry,
    createProxyMiddleware({
      target: oryWhoamiUrl,
      changeOrigin: true,
      ignorePath: true,
      on: {
        proxyRes: (proxyRes, req, res) => {
          if (res.statusCode !== 200) return // only cache http status 200 responses
          const cookie = req.cookies[orySessionKey]
          let body = ''

          proxyRes.on('data', (chunk) => {
            body += chunk
          })

          proxyRes.on('end', () => {
            try {
              const data = JSON.parse(body)
              cache.set(cookie, data)
            } catch (e) {
              // ignore if not a JSON body
            }
          })
        },
      },
    }),
  )
}
