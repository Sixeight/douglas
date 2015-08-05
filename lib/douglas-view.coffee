{$$, SelectListView} = require 'atom-space-pen-views'
path = require 'path'
fuzzaldrin = require 'fuzzaldrin'
ghq = require './ghq'

module.exports =
class DouglasView extends SelectListView
  roots: []

  initialize: ->
    super
    @addClass('douglas')
    ghq.rootAll (outputs) =>
      @roots = outputs.trim().split('\n')

  viewForItem: (fullPath) ->
    relativePath = fullPath
    for root in @roots
      continue if relativePath.indexOf(root) <= -1
      relativePath = relativePath.substring(root.length + 1)

    filterQuery = @getFilterQuery()
    matches = fuzzaldrin.match(relativePath, filterQuery)

    basePath = path.basename fullPath
    baseOffset = relativePath.length - basePath.length

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
        @div class: 'primary-line file icon icon-repo', -> highlighter(basePath, matches, baseOffset)
        @div class: 'secondary-line path no-icon', -> highlighter(relativePath, matches, 0)

  confirmed: (item) ->
    @panel?.hide()
    atom.open pathsToOpen: [item]

  toggle: ->
    if @panel?.isVisible() then @cancel() else @show()

  show: ->
    @storeFocusedElement()
    @process = @_fetchList (paths) =>
      return if paths.length <= 0
      @setItems paths
      @panel ?= atom.workspace.addModalPanel(item: this)
      @panel.show()
      @focusFilterEditor()

  hide: ->
    @panel?.hide()
    @process?.kill?()
    @process = null

  cancelled: ->
    @hide()

  _fetchList: (callback) ->
    ghq.list '--full-path', (outputs) ->
      callback outputs.split '\n'
