import { buildChallengesUrl } from '../url'

describe('url', () => {
  describe('buildChallengesUrl', () => {
    test('should leave the url unchanged when there is no auth header', () => {
      const url = buildChallengesUrl('', 'challenges/1')

      expect(url).toEqual('https://challenges.holi/challenges/1')
    })

    test('should transfer jwt token from header to querystring when there is an auth header', () => {
      const url = buildChallengesUrl('Bearer token-1234-shhh', 'challenges/1')

      expect(url).toEqual('https://challenges.holi/challenges/1?session=token-1234-shhh')
    })

    test('should append token correctly when the challenges path already has a querystring', () => {
      const url = buildChallengesUrl('Bearer token-1234-shhh', 'challenges/1?referrerPath=%2F')

      expect(url).toEqual('https://challenges.holi/challenges/1?referrerPath=%2F&session=token-1234-shhh')
    })

    test('should insert "/" regardless of whether path is prefixed with it or not', () => {
      let url = buildChallengesUrl('', 'challenges/1')
      expect(url).toEqual('https://challenges.holi/challenges/1')

      url = buildChallengesUrl('', '/challenges/1')
      expect(url).toEqual('https://challenges.holi/challenges/1')
    })
  })
})
