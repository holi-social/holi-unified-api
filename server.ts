import { createServer } from 'node:http'

import { createBuiltMeshHTTPHandler } from './.mesh'

const server = createServer(createBuiltMeshHTTPHandler())
server.listen(4000)
