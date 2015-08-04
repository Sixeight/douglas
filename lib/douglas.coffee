DouglasView = require './douglas-view'
{CompositeDisposable} = require 'atom'

module.exports = Douglas =
  douglasView: null
  modalPanel: null
  subscriptions: null

  activate: (state) ->
    @subscriptions = new CompositeDisposable
    @subscriptions.add atom.commands.add 'atom-workspace',
      'douglas:toggle': => @toggle()

  deactivate: ->
    @modalPanel.destroy()
    @subscriptions.dispose()
    @douglasView.destroy()

  serialize: ->
    douglasViewState: @douglasView.serialize()

  toggle: ->
    @douglasView = new DouglasView()
