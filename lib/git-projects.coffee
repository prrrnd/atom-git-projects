fs = require 'fs'
path = require 'path'

GitProjectsView = require './git-projects-view'

module.exports =
  config:
    rootPath:
      type: 'string'
      default: process.env["HOME"] + path.sep + "repos"

  gitProjectsView: null

  activate: (state) ->
    atom.commands.add 'atom-workspace',
      'git-projects:toggle': =>
        @createGitProjectsViewView(state).toggle(@)

  openProject: (project) ->
    atom.open options =
      pathsToOpen: [project.path]

  createGitProjectsViewView: (state) ->
      @gitProjectsView ?= new GitProjectsView()
