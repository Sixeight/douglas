{$$, SelectListView} = require 'atom-space-pen-views'
path = require 'path'
fuzzaldrin = require 'fuzzaldrin'
ghq = require './ghq'

module.exports =
class DouglasView extends SelectListView
  initialize: ->
    super
    @addClass('douglas')

  viewForItem: (fullPath) ->
    filterQuery = @getFilterQuery()
    matches = fuzzaldrin.match(fullPath, filterQuery)

    basePath = path.basename fullPath
    offset = fullPath.length - basePath.length

    $$ ->
      # inspired by fuzzy-finder
      highlighter = (text, matches, offsetIndex) =>
        lastIndex = 0
        matchedChars = []

        for matchIndex in matches
          matchIndex -= offsetIndex
          continue if matchIndex < 0
          unmatched = text.substring(lastIndex, matchIndex)
          if unmatched
            @span matchedChars.join(''), class: 'character-match' if matchedChars.length
            matchedChars = []
            @text unmatched
          matchedChars.push(text[matchIndex])
          lastIndex = matchIndex + 1

        @span matchedChars.join(''), class: 'character-match' if matchedChars.length

        # Remaining characters are plain text
        @text text.substring(lastIndex)

      @li class: 'two-lines', =>
        @div class: 'primary-line file icon icon-repo', -> highlighter(basePath, matches, offset)
        @div fullPath, class: 'secondary-line path no-icon'

  confirmed: (item) ->
    @panel?.hide()
    atom.open pathsToOpen: [item]

  toggle: ->
    if @panel?.isVisible() then @cancel() else @show()

  show: ->
    @storeFocusedElement()
    @panel ?= atom.workspace.addModalPanel(item: this)
    @process = @_fetchList (paths) =>
      @setItems paths
      @panel.show()
      @focusFilterEditor()

  hide: ->
    @panel?.hide()
    @process?.kill()
    @process = null

  cancelled: ->
    @hide()

  _fetchList: (callback) ->
    ghq.list '--full-path', (outputs) ->
      callback outputs.split '\n'
