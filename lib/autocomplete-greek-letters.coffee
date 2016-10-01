provider = require('./greek-letters-provider')

module.exports =
  config:
    enableUnicodeEmojis:
      type: 'boolean'
      default: true
    enableMarkdownEmojis:
      type: 'boolean'
      default: true

  activate: ->
    provider.loadProperties()

  getProvider: -> provider
