const requiredPlugins = [
  '@babel/plugin-proposal-class-properties',
  '@babel/plugin-proposal-optional-chaining'
]

const plugins = {
  development: requiredPlugins,
  test: requiredPlugins,
  production: [
    ...requiredPlugins,
    '@babel/plugin-transform-spread',
    '@babel/plugin-proposal-object-rest-spread'
  ]
}

const development = [
  [
    '@babel/preset-env',
    {
      targets: {
        browsers: 'last 1 chrome version'
      },
      useBuiltIns: 'entry',
      loose: true,
      shippedProposals: true
    }
  ]
]

const presets = {
  development,
  test: development,
  production: [
    [
      '@babel/preset-env',
      {
        targets: {
          browsers: 'defaults, ie 11'
        },
        useBuiltIns: 'entry'
      }
    ]
  ]
}

module.exports = api => {
  const env = api.env()
  return {
    plugins: plugins[env],
    presets: presets[env]
  }
}
