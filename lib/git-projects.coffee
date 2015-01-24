fs = require 'fs'
path = require 'path'
utils = require './utils'

GitProjectsView = require './git-projects-view'

projects = []
module.exports =
  config:
    rootPath:
      title: "Path to the directory from which Git projects should be searched for"
      type: "string"
      default: utils.getHomeDir() + path.sep + "repos"
    sortBy:
      title: "Sort by"
      type: "string"
      default: "Project name"
      enum: ["Project name", "Latest modification date"]

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

  getGitProjects: (rootPath) ->
    if fs.existsSync(rootPath)
      gitProjects = fs.readdirSync(rootPath)
      for index, project of gitProjects
        projectPath = rootPath + project
        if utils.isGitProject(projectPath)
          projects.push({title: project, path: projectPath})
        else if fs.lstatSync(projectPath).isDirectory()
          @getGitProjects(projectPath + path.sep)

    return utils.sortBy(projects)

  clearProjectsList: ->
    projects = []
