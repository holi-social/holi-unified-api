import http from 'k6/http'
import { check } from 'k6'

const VIRTUAL_USERS = 1
const REQUESTS_PER_VIRTUAL_USER = 1

const allChecksNeedToPassTreshold = { checks: [{ threshold: 'rate==1', abortOnFail: true }] }

export const options = {
  vus: VIRTUAL_USERS,
  iterations: REQUESTS_PER_VIRTUAL_USER,
  thresholds: allChecksNeedToPassTreshold,
}

export default () => {
  const params = {
    headers: {
      'Content-Type': 'application/json',
    },
  }
  const query = `
    query {
      topics {
        totalResults
      }
    }
  `

  const response = http.post(__ENV.BASE_URL, JSON.stringify({ query }), params)

  check(response, {
    'is status 200': (r) => r.status === 200,
  })

  check(JSON.parse(response.body), {
    'contains totalResults count': (r) => typeof r.data.topics.totalResults == 'number',
  })
}
