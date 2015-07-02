git = require 'git-utils'
_path = require 'path'
CSON = require 'season'
fs = require 'fs'

{Task} = require 'atom'
ReadGitInfoTask = require.resolve '../read-git-info-task'
TaskPool = require '../task-pool'

class Project
  # For caching
  _stale: false
  setStale: (value) -> @_stale = value
  isStale: -> @_stale

  # Properties
  dirty: null
  branch: null

  @deserialize: (instance) ->
    new ProjectDeserialized instance

  constructor: (@path) ->
    @icon = "icon-repo"
    @ignored = false
    @title = _path.basename(@path)
    @readConfigFile()

  readGitInfo: (cb) ->
    task = new Task(ReadGitInfoTask)
    TaskPool.add task, @path, (data) =>
      @branch = data.branch
      @dirty = data.dirty
      cb()

  hasGitInfo: ->
    @branch? and @dirty?

  readConfigFile: ->
    filepath = @path + _path.sep + ".git-project"
    if fs.existsSync(filepath)
      data = CSON.readFileSync(filepath)
      if data?
        @title = data['title'] if data['title']?
        @ignored = data['ignore'] if data['ignore']?
        @icon = data['icon'] if data['icon']?

class ProjectDeserialized extends Project
  constructor: (instance) ->
    @path = instance.path
    @icon = instance.icon
    @ignored = instance.ignored
    @title = instance.title
    @dirty = instance.dirty
    @branch = instance.branch

module.exports = Project
