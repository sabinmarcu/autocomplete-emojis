fs = require('fs')
path = require('path')
fuzzaldrin = require('fuzzaldrin')
emojis = require("emoji-data")

module.exports =
    selector: '*'

    emojimap: {}
    emojikeys: []

    symbolmap: {}
    symbolkeys: []

    loadProperties: ->
        fs.readFile path.resolve(__dirname, '..', 'letters.json'), (error, content) =>
            return if error

            @symbolmap = JSON.parse(content)
            @symbolkeys = Object.keys(@symbolmap)

            all = emojis.all()
            @emojimap = all.reduce((prev, it) ->
                prev[it.short_name] = it
                prev
            , {})
            @emojikeys = Object.keys(@emojimap)

    getSuggestions: ({prefix}) ->
        return [] unless prefix?.length >= 2
        return []
            .concat(@getUnicodeGreekLetterSuggestions(prefix))
            .concat(@getUnicodeEmojiSuggestions(prefix))

    getUnicodeGreekLetterSuggestions: (prefix) ->
        words = fuzzaldrin.filter(@symbolkeys, prefix)
        words.map (word) =>
            {
                text: String.fromCodePoint(@symbolmap[word])
                replacementPrefix: prefix
                rightLabel: word
                description: "Greek Symbol"
                type: "keyword"
            }

            poo

    getUnicodeEmojiSuggestions: (prefix) ->
        words = fuzzaldrin.filter(@emojikeys, prefix)
        words.map (word) =>
            {
                text: @emojimap[word].render()
                replacementPrefix: prefix
                rightLabel: word
                description: "Emoji 👐"
                type: "keyword"
            }
