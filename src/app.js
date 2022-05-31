import { faker } from '@faker-js/faker'
import { ApolloServerPluginDrainHttpServer, gql } from 'apollo-server-core'
import { ApolloServer } from 'apollo-server-express'
import { program } from 'commander'
import express from 'express'
import { readFileSync } from 'fs'
import http from 'http'

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
  return {
    id: faker.unique(faker.datatype.uuid),
    name: `${faker.name.firstName()} ${faker.name.lastName()}`,
    aboutMe: faker.lorem.lines(),
    pronouns: pronouns[randomInt(0, pronouns.length - 1)],
    location: `${faker.address.city()}, ${faker.address.country()}`,
  }
}

const fakeUsers = Array.from({ length: randomInt(0, 100) }, fakeUser)

console.info(`${fakeUsers.length} fake user(s)`)

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
  plugins: [ApolloServerPluginDrainHttpServer({ httpServer })],
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
