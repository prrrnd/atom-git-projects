fs = require 'fs'
path = require 'path'
utils = require './utils'
settings = require './settings'
GitProjectsView = require './views/git-projects-view'
Project = require './models/project'

module.exports =
  config:
    rootPath:
      title: "Path to the directory from which Git projects should be searched for"
      type: "string"
      default: settings.getDefaultRootPath()
    sortBy:
      title: "Sort by"
      type: "string"
      default: "Project name"
      enum: ["Project name", "Latest modification date"]
    showSubRepos:
      title: "Show sub-repositories"
      type: "boolean"
      default: false

  projects: []
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
      for index, name of gitProjects
        projectPath = rootPath + name
        if fs.lstatSync(projectPath).isDirectory()
          if utils.isGitProject(projectPath)
            @projects.push(new Project(name, projectPath))
            if atom.config.get('git-projects.showSubRepos')
              @getGitProjects(projectPath + path.sep)
          else @getGitProjects(projectPath + path.sep)

    return utils.sortBy(@projects)

  clearProjectsList: ->
    @projects = []
