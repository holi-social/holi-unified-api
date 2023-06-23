import { createServer } from 'node:http'

import { createBuiltMeshHTTPHandler } from './.mesh'

console.log('======== SERVER STARTING ========')

const server = createServer(createBuiltMeshHTTPHandler())
server.listen(4000)
