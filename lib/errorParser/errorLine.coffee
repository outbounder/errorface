crypto = require "crypto"


descriptRegex = new RegExp("^(.*): (.*)$")
atRegex = new RegExp(".*?at (.*) \\((.*?):(.*?):(.*?)\\)")


makeHash = (str) -> crypto.createHash("md5").update(str).digest("hex")

projectPath = process.cwd()
makeRelativePath = (path) -> path.replace(projectPath, '').replace("/node_modules", "[module]")

class ErrorLine 
    constructor: (line) ->
        @parse line

    parse: (line) ->
        throw new Error("Must provide line") if not line

        match = descriptRegex.exec line

        return @_fillForDescript match if match

        match = atRegex.exec line

        return @_fillForAt match if match

        throw new Error("Unable to parse error line: #{line}")

    _fillForDescript: (match) ->
        @type = "description"
        @details = 
            error: match[1]
            message: match[2]

    _fillForAt: (match) ->
        @type = "file"

        @details = 
            method: match[1]
            file: match[2]
            fileHash: makeHash match[2]
            fileRelative: makeRelativePath match[2]
            line: parseInt match[3], 10
            column: parseInt match[4], 10


module.exports = ErrorLine