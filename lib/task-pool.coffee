os = require 'os'

class TaskPool
  liveCount: 0
  tasks: []
  working: false

  constructor: (@size=4) ->

  run: ->
    @working = true
    interval = null

    work = =>
      return clearInterval(interval) unless @working
      return if @liveCount >= @size
      return @stop() unless @tasks.length

      {task, args, callback} = @tasks.shift()
      task.on 'result', callback

      @liveCount++
      task.start args..., => @liveCount--

    interval = setInterval(work, 10)

  stop: ->
    @working = false

  add: (task, args..., callback) ->
    @tasks.push {task, args, callback}
    @run() unless @working

module.exports =
  new TaskPool Math.max(os.cpus().length - 2, 1)
