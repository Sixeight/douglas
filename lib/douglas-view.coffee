{$$, SelectListView} = require 'atom-space-pen-views'
{BufferedProcess} = require 'atom'
path = require 'path'

module.exports =
class DouglasView extends SelectListView
  initialize: ->
    super
    @addClass('douglas')
    @panel ?= atom.workspace.addModalPanel(item: this)
    @process = @fetchList =>
      @panel.show()
      @focusFilterEditor()

  viewForItem: (fullPath) ->
    basePath = path.basename fullPath
    $$ ->
      @li class: 'two-lines', =>
        @div basePath, class: 'primary-line file icon icon-repo'
        @div fullPath, class: 'secondary-line path no-icon'

  confirmed: (item) ->
    @panel?.hide()
    atom.open pathsToOpen: [item]
    atom.focus()

  cancelled: ->
    @panel?.hide()
    @process?.kill()
    @process = null

  fetchList: (callback) ->
    paths = []
    command = 'ghq'
    args = ['list', '--full-path']
    stdout = (output) =>
       paths = paths.concat output.split('\n')
    exit = (code) =>
      return unless code == 0
      @setItems paths
      callback()
    new BufferedProcess({command, args, stdout, exit})
