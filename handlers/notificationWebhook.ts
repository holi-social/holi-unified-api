import { createHmac } from 'crypto'
import { createProxyMiddleware } from 'http-proxy-middleware'
import { Express } from 'express'

export const setupNotificationWebhook = (app: Express, webhookUrl: string) => {
  // Notification webhook receiver to validate the incoming request using HMAC and forward it to okuna to process it.
  const novuSignature = createHmac('sha256', process.env.NOVU_API_KEY)
    .update(process.env.NOVU_ENVIRONMENT_ID)
    .digest('hex')

  app.post(webhookUrl, async (req, res, next) => {
    const hmac = req.headers['nv-hmac-256']
    if (hmac !== novuSignature) {
      res.status(401).send('Unauthorized')
      return
    } else {
      next()
    }
  })
  app.post(webhookUrl, createProxyMiddleware(webhookUrl, {
    target: process.env.OKUNA_DOMAIN,
    changeOrigin: true,
  }))
}
