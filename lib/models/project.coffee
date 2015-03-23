git = require 'git-utils'
CSON = require 'season'

module.exports =
class Project
  constructor: (@title, @path, @icon, @ignored) ->
    @readConfigFile()

  isDirty: ->
    repository = git.open @path
    Object.keys(repository.getStatus()).length != 0

  branch: ->
    repository = git.open @path
    repository.getShortHead()

  readConfigFile: ->
    filepath = @path + path.sep + ".git-project"
    if fs.existsSync(filepath)
      data = CSON.readFileSync(filepath)
      if data?
        @title = data['title'] if data['title']?
        @ignored = data['ignore'] if data['ignore']?
        @icon = data['icon'] if data['icon']?
