module.exports = {
  setupFiles: ['<rootDir>/tests/setEnvVars.ts'],
  preset: 'ts-jest',
  testEnvironment: 'node',
  resetMocks: true,
}
