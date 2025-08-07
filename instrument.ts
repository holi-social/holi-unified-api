import * as Sentry from '@sentry/node'

const environment = process.env.ENVIRONMENT_ID || 'development'

Sentry.init({
  dsn: 'https://72908d154fdea414c5ca260f75fe400e@o949544.ingest.us.sentry.io/4509792244989952',
  tracesSampleRate: 0.3,
  tracePropagationTargets: ['localhost', /^\//, 'dev.holi.social', 'app.holi.social'],
  enabled: ['staging', 'production'].includes(environment),
  environment: environment,
  beforeSendTransaction: (event) => {
    try {
      if (event.transaction === 'POST /graphql' && event.request?.data) {
        const payload = JSON.parse(event.request.data as string)
        event.transaction = `/graphql ${payload.operationName}`
      }
    } catch {}

    return event
  },
})
