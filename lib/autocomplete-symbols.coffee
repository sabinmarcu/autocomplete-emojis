provider = require('./symbols-provider')

module.exports =
  config:
    enableEmojis:
      type: 'boolean'
      default: true
    enableSymbols:
      type: 'boolean'
      default: true

  activate: ->
    provider.loadProperties()

  getProvider: -> provider
