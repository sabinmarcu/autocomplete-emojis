fs = require('fs')
path = require('path')
fuzzaldrin = require('fuzzaldrin')

module.exports =
    selector: '*'

    properties: {}
    keys: []

    loadProperties: ->
        fs.readFile path.resolve(__dirname, '..', 'letters.json'), (error, content) =>
            return if error

            @properties = JSON.parse(content)
            @keys = Object.keys(@properties)

    getSuggestions: ({prefix}) ->
        return [] unless prefix?.length >= 2
        return @getUnicodeGreekLetterSuggestions(prefix)

    getUnicodeGreekLetterSuggestions: (prefix) ->
        words = fuzzaldrin.filter(@keys, prefix)
        words.map (word) =>
            {
                text: String.fromCodePoint(@properties[word])
                replacementPrefix: prefix
                rightLabel: word
                description: "Greek Symbol"
                type: "keyword"
            }
