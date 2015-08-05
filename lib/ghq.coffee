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

    new BufferedProcess({@command, args, stdout, exit})
