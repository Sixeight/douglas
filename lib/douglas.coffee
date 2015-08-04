DouglasView = require './douglas-view'
{CompositeDisposable} = require 'atom'

module.exports = Douglas =
  douglasView: null
  modalPanel: null
  subscriptions: null

  activate: (state) ->
    @douglasView = new DouglasView(state.douglasViewState)
    @modalPanel = atom.workspace.addModalPanel(item: @douglasView.getElement(), visible: false)

    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace', 'douglas:toggle': => @toggle()

  deactivate: ->
    @modalPanel.destroy()
    @subscriptions.dispose()
    @douglasView.destroy()

  serialize: ->
    douglasViewState: @douglasView.serialize()

  toggle: ->
    console.log 'Douglas was toggled!'

    if @modalPanel.isVisible()
      @modalPanel.hide()
    else
      @modalPanel.show()
