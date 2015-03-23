git = require 'git-utils'

module.exports =
class Project
  constructor: (@title, @path, @icon, @ignored) ->

  isDirty: ->
    repository = git.open @path
    Object.keys(repository.getStatus()).length != 0

  branch: ->
    repository = git.open @path
    repository.getShortHead()
