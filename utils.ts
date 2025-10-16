import { exit } from 'process'

export const buildChallengesUrl = (authHeader: string, challengesPath: string) => {
  let queryParameter = ''
  const pathSeparator = challengesPath.startsWith('/') ? '' : '/'

  if (authHeader.startsWith('Bearer ')) {
    const jwtSession = authHeader.replace('Bearer ', '')
    const separator = challengesPath.indexOf('?') === -1 ? '?' : '&'
    queryParameter = `${separator}session=${jwtSession}`
  }

  return `${process.env.CHALLENGES_URL}${pathSeparator}${challengesPath}${queryParameter}`
}

export const asNumber = (str?: string) => (str ? Number(str) : undefined)

export const ensureEnv = (key: string) => {
  const val = process.env[key]
  if (val) return val
  console.error(`Environment variable ${key} is not specified. Exiting.`)
  exit(1)
}
