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
