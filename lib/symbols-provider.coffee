fs = require('fs')
path = require('path')
fuzzaldrin = require('fuzzaldrin')
emojis = require("emoji-data")
rp = require("request-promise-native")

pkginfo = require path.resolve __dirname, "..", "package.json"

merge = (dest, objs...) ->
    for obj in objs
        dest[k] = v for k, v of obj
    dest

toCodePointFunction = (content) ->
    for k, v of content then content[k] = String.fromCodePoint v
    content

analyzeJson = (content, map, keys, func = toCodePointFunction) ->
    content = func if content.all? then content.all() else JSON.parse content
    map = merge map, content
    keys = keys.concat Object.keys content
    [map, keys]

module.exports =
    selector: '*'

    emojimap: {}
    emojikeys: []

    symbolmap: {}
    symbolkeys: []


    loadProperties: ->
        loaders = []

        @symbolmap = {}
        @symbolkeys = []

        urls = atom.config.get pkginfo.name + ".symbolUrls"
        if urls && urls.length > 0
            urls.map (url) =>
                loaders.push rp(url).then (data) => [@symbolmap, @symbolkeys] = analyzeJson data, @symbolmap, @symbolkeys
        else
            loaders.push new Promise (accept, reject) =>
                fs.readFile path.resolve(__dirname, '..', 'letters.json'), (err, data) =>
                    return reject(err) if err

                    accept [@symbolmap, @symbolkeys] = analyzeJson data, @symbolmap, @symbolkeys

        @emojimap = {}
        @emojikeys = []

        urls = atom.config.get pkginfo.name + ".emojiUrls"
        if urls && urls.length > 0
            urls.map (url) =>
                loaders.push rp(url).then (data) => [@emojimap, @emojikeys] = analyzeJson data, @emojimap, @emojikeys

        else
            loaders.push new Promise (accept, reject) =>
                accept [@emojimap, @emojikeys] = analyzeJson emojis, @emojimap, @emojikeys, (all) ->
                    all.reduce (prev, it) ->
                        prev[it.short_name] = it.render()
                        prev
                    , {}

        console.log loaders
        Promise.all(loaders).then () => console.log [@symbolkeys, @symbolmap], [@emojikeys, @emojimap]

    getSuggestions: ({prefix, scopeDescriptor}) ->

        selectors = (atom.config.get pkginfo.name + ".emojiSelectors").map (selector) -> new RegExp selector
        shouldAddEmoji = scopeDescriptor.scopes.reduce(
            (prev, scope) -> prev || selectors.reduce(((acc, it) -> acc || scope.match(it)), false)
        , false)

        selectors = (atom.config.get pkginfo.name + ".symbolsSelectors").map (selector) -> new RegExp selector
        shouldAddSymbols = scopeDescriptor.scopes.reduce(
            (prev, scope) -> prev || selectors.reduce(((acc, it) -> acc || scope.match(it)), false)
        , false)

        return [] unless prefix?.length >= 2
        return []
            .concat(atom.config.get(pkginfo.name + ".enableSymbols") && shouldAddSymbols && @getUnicodeGreekLetterSuggestions(prefix) || [])
            .concat(atom.config.get(pkginfo.name + ".enableEmojis") && shouldAddEmoji && @getUnicodeEmojiSuggestions(prefix) || [])

    getUnicodeGreekLetterSuggestions: (prefix) ->
        words = fuzzaldrin.filter(@symbolkeys, prefix)
        words.map (word) =>
            {
                text: @symbolmap[word]
                replacementPrefix: prefix
                rightLabel: word
                description: "Greek Symbol"
                type: "keyword"
            }

    getUnicodeEmojiSuggestions: (prefix) ->
        words = fuzzaldrin.filter(@emojikeys, prefix)
        words.map (word) =>
            {
                text: @emojimap[word]
                replacementPrefix: prefix
                rightLabel: word
                description: "Emoji"
                type: "keyword"
            }
