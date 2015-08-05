{BufferedProcess} = require 'atom'

module.exports = ghq =
  command: 'ghq'

  list: (args..., callback) ->
    args.unshift('list')
    @run args, callback

  run: (args, callback) ->
    outputs = ''

    stdout = (output) ->
      outputs += output
    exit = (code) ->
      return unless code == 0
      callback outputs

    process = new BufferedProcess({@command, args, stdout, exit})
    process.onWillThrowError (error) ->
      message = 'Douglas is unable to locate `ghq` command.<br />' +
                'Make sure ghq is installed and on your PATH.<br />' +
                'see also: https://github.com/motemen/ghq'
      atom.notifications.addError message, dismissable: true
      error.handle()
    process
