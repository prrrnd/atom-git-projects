git = require 'git-utils'

module.exports =
class Project
  isDirty: null

  constructor: (@title, @path, @icon, @ignored) ->

  isDirty: ->
    if typeof @isDirty == 'boolean'
      @isDirty
    else
      @repository = git.open( @path )
      @isDirty = Object.keys( @repository.getStatus() ).length == 0
