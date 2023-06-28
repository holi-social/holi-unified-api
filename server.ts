import express from 'express'

import { createBuiltMeshHTTPHandler } from './.mesh'

const asNumber = (str?: string) => (str ? Number(str) : undefined)

const port = asNumber(process.env.PORT) || 4000

console.debug(`Server starting on port ${port}`)

const app = express()

app.use('/graphql', createBuiltMeshHTTPHandler())

app.listen(4000, () => {
  console.info(`Server listening on port ${port}`)
})
