{$} = require 'atom'
_ = require 'underscore-plus'

class Side
  constructor: (@marker) ->
    @conflict = null

  text: -> @lines.text()

  resolve: -> @conflict.resolution = @

  wasChosen: -> @conflict.resolution is @

class OurSide extends Side

  site: -> 1

  klass: -> 'ours'

  description: -> 'our changes'

class TheirSide extends Side

  site: -> 2

  klass: -> 'theirs'

  description: -> 'their changes'

CONFLICT_REGEX = /^<{7} (\S+)\n([^]*?)={7}\n([^]*?)>{7} (\S+)$/m

module.exports =
class Conflict
  constructor: (@ours, @theirs, @parent) ->
    ours.conflict = @
    theirs.conflict = @
    @resolution = null

  @all: (editor) ->
    results = []
    buffer = editor.getBuffer()
    buffer.scan CONFLICT_REGEX, (m) ->
      [x, ourRef, ourText, theirText, theirRef] = m.match
      [baseRow, baseCol] = m.range.start.toArray()

      ourLines = ourText.split /\n/
      ourRowStart = baseRow + 1
      ourRowEnd = ourRowStart + ourLines.length - 1

      console.log ourLines
      ourMarker = editor.markBufferRange(
        [[ourRowStart, 0], [ourRowEnd, 0]])

      ours = new OurSide(ourMarker)

      theirLines = theirText.split /\n/
      theirRowStart = ourRowEnd + 1
      theirRowEnd = theirRowStart + theirLines.length - 1

      theirMarker = editor.markBufferRange(
        [[theirRowStart, 0], [theirRowEnd, 0]])

      theirs = new TheirSide(theirMarker)

      results.push new Conflict(ours, theirs, null)
    results
