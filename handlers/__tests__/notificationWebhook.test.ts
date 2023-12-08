import { Server } from 'http';
import { Mockttp, getLocal } from 'mockttp'
import request from 'supertest'

import { NOVU_SIGNATURE_HEADER, setupNotificationWebhook } from '../notificationWebhook'
import express from 'express'

describe('Notification Webhook', () => {
  let server: Server
  const mockOkuna: Mockttp = getLocal()
  const webhookUrl = '/notification-webhook'
  const expectedNovuSignature = 'e6413e5ce7c4ef6a24f61b06687d199d8d94c59dc545e705226a2936a06cfcc3'

  beforeAll(async () => {
    await mockOkuna.start()
    process.env = {
      NOVU_API_KEY: 'TEST',
      NOVU_ENVIRONMENT_ID: 'TEST',
      OKUNA_DOMAIN: mockOkuna.url
    }
    const app = express()
    setupNotificationWebhook(app, '/notification-webhook')
    server = app.listen()
  })

  afterAll(async () => {
    server?.close()
    await mockOkuna.stop()
  })

  it('should reject requests without signature', async () => {
    return request(server).post(webhookUrl)
      .expect(401, 'Unauthorized')
  })

  it('should reject requests with invalid signature', async () => {
    return request(server)
      .post(webhookUrl)
      .set(NOVU_SIGNATURE_HEADER, 'invalid')
      .expect(401, 'Unauthorized')
  })

  it('should accept requests with valid signature', async () => {
    mockOkuna.forPost('/notification-webhook').thenReply(200, 'MOCK OK')
    await request(server)
      .post(webhookUrl)
      .set(NOVU_SIGNATURE_HEADER, expectedNovuSignature)
      .expect(200, 'MOCK OK')
  })
})
