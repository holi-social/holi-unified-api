import pino from 'pino'

const GCloudLogLevelMapping= {
  trace: 'DEBUG',
  debug: 'DEBUG',
  info: 'INFO',
  warn: 'WARNING',
  error: 'ERROR',
  fatal: 'CRITICAL',
}

const mapToGCloudSeverity= (level: string) => {
  return level in GCloudLogLevelMapping ? GCloudLogLevelMapping[level as keyof typeof GCloudLogLevelMapping] : GCloudLogLevelMapping.info
}

const logger = pino({
  formatters: {
    level(level, number) {
      return {
        severity: mapToGCloudSeverity(level),
        level: number,
      }
    },
    log(entry) {
      const error = entry.err
      return { ...entry, ...(error instanceof Error && { stack_trace: error.stack }) }
    },
  },
  mixin() {
    return {
      'logging.googleapis.com/labels': {
        environment: process.env.ENVIRONMENT_ID || process.env.NEXT_PUBLIC_ENVIRONMENT_ID || 'development',
        service: 'holi-unified-api',
      },
    }
  },
  messageKey: 'message',
  level: 'info',
})

export default logger
