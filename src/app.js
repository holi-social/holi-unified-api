import apolloClientGlobal from '@apollo/client/core/core.cjs'
import { faker } from '@faker-js/faker'
import {
  ApolloServerPluginDrainHttpServer,
  ApolloServerPluginLandingPageGraphQLPlayground,
  gql,
} from 'apollo-server-core'
import { ApolloServer } from 'apollo-server-express'
import { program } from 'commander'
import express from 'express'
import { readFileSync } from 'fs'
import http from 'http'
import fetch from 'node-fetch'

const { ApolloClient, HttpLink, InMemoryCache } = apolloClientGlobal

const DEFAULT_PORT = 4001

program.option('--port <number>', `port on which to run the server (default: ${DEFAULT_PORT}`)

program.parse()

const options = program.opts()
const port = options.port ? parseInt(options.port, 10) : DEFAULT_PORT

const randomInt = (min, max) => {
  return Math.floor(Math.random() * (max - min + 1) + min)
}

const fakeUser = () => {
  const pronouns = ['they/them', 'she/her', 'he/him', '']
  const engagementLevel = ['low', 'middle', 'high']
  const interests = ['Nature', 'Sustainability', 'Migration', 'Climate', 'BLM', 'Feminism', 'Workers rights', 'Forests']
  const sdgs = ['No Poverty', 'Zero Hunger', 'Good Health and Well-being', 'Quality Education', 'Gender equality']
  const skills = [
    'Driving',
    'Cooking',
    'Craft',
    'Cleaning',
    'Organising',
    'Leading',
    'Hosting',
    'First aid',
    'Coaching',
  ]

  return {
    id: faker.unique(faker.datatype.uuid),
    image: faker.image.image(50, 50),
    firstName: faker.name.firstName(),
    middleName: faker.name.middleName(),
    lastName: faker.name.lastName(),
    aboutMe: faker.lorem.lines(),
    pronouns: pronouns[randomInt(0, pronouns.length - 1)],
    location: `${faker.address.city()}, ${faker.address.country()}`,
    engagementLevel: engagementLevel[randomInt(0, engagementLevel.length - 1)],
    interests: interests.slice(0, randomInt(1, interests.length - 1)),
    sdgs: sdgs.slice(0, randomInt(1, sdgs.length - 1)),
    skills: skills.slice(0, randomInt(1, skills.length - 1)),
  }
}

const fakeUsers = Array.from({ length: randomInt(1, 100) }, fakeUser)
console.info(`${fakeUsers.length} fake user(s)`)

const okunaUrl = process.env.OKUNA_URL || 'http://localhost:4000/graphql'
console.info(`connecting to okuna via '${okunaUrl}',`)
const okunaClient = new ApolloClient({
  link: new HttpLink({ uri: process.env.OKUNA_URL || 'http://localhost:4000/graphql', fetch }),
  cache: new InMemoryCache(),
})

const typeDefs = gql(readFileSync('./schema.graphql').toString('utf-8'))
const resolvers = {
  Query: {
    allUsers: (_, args) => {
      console.info('allUsers', args)
      const offset = args.offset || 0
      const limit = args.limit || fakeUsers.length
      const result = fakeUsers.slice(offset, offset + limit)
      return result
    },
    user: (_, args) => {
      const userFound = fakeUsers.find((u) => u.id === args.id)
      console.info('user', args)
      return userFound
    },
    // used for checking the availability of the service in the docker container, see oathkeeper/start.sh
    ping: () => {
      return 'pong'
    },
    okunaUsers: () => {
      console.info('okunaUsers')
      return okunaClient
        .query({
          query: gql`
            {
              allUsers {
                id
              }
            }
          `,
        })
        .then((result) => {
          console.log(result)
          if (result && result.data && result.data.allUsers) {
            return result.data.allUsers
          } else {
            return []
          }
        })
    },
  },
  Mutation: {
    createUser: (_, args) => {
      const newUser = {
        ...fakeUser(),
        ...args.user,
      }
      fakeUsers.push(newUser)
      console.info('createUser', newUser)
      return newUser
    },
    updateUser: (_, args) => {
      const userIndex = fakeUsers.findIndex((u) => u.id === args.id)
      const updatedUser = {
        ...fakeUsers[userIndex],
        ...args.user,
      }
      fakeUsers[userIndex] = updatedUser
      console.info('updateUser', updatedUser)
      // Return user with id for automatic cache updates
      return updatedUser
    },
  },
}

const app = express()
const httpServer = http.createServer(app)
const server = new ApolloServer({
  typeDefs,
  resolvers,
  plugins: [ApolloServerPluginDrainHttpServer({ httpServer }), ApolloServerPluginLandingPageGraphQLPlayground()],
})
server
  .start()
  .then(() => {
    server.applyMiddleware({ app, cors: true })
    return new Promise((resolve) => httpServer.listen({ port }, resolve))
  })
  .then(() => {
    console.info(`Server up and running at http://localhost:${port}/graphql`)
  })
