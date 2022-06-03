module.exports = {
  env: {
    node: true,
    es2018: true,
  },
  root: true,
  extends: ['eslint:recommended', 'prettier'],
  parserOptions: {
    sourceType: 'module',
  },
  plugins: ['prefer-arrow', 'prettier'],
  rules: {
    'prettier/prettier': ['error'],
    'linebreak-style': ['error', 'unix'],
    quotes: ['error', 'single'],
    semi: ['error', 'never'],
    'prefer-arrow/prefer-arrow-functions': [
      'error',
      {
        disallowPrototype: true,
        singleReturnOnly: false,
        classPropertiesAllowed: false,
      },
    ],
    'no-restricted-imports': [
      'error',
      {
        // Allows relative imports only within the current directory, forbids all other relative imports
        patterns: ['..*'],
      },
    ],
  },
}
