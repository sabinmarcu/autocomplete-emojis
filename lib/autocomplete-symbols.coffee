provider = require('./symbols-provider')

module.exports =
    config:
        enableEmojis:
            order: 2
            type: 'boolean'
            default: true
        enableSymbols:
            order: 1
            type: 'boolean'
            default: true
        emojiSelectors:
            order: 4,
            type: 'array'
            default: ['comment','string']
            items:
                type: 'string'
        symbolSelectors:
            order: 3,
            type: 'array'
            default: []
            items:
                type: 'string'
        emojiUrls:
            order: 6
            type: 'array'
            default: []
            items:
                type: 'string'
        symbolUrls:
            order: 5
            type: 'array'
            default: []
            items:
                type: 'string'

    activate: ->
        provider.loadProperties()

    getProvider: -> provider
