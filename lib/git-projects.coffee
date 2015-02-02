fs = require 'fs'
path = require 'path'
utils = require './utils'
settings = require './settings'
CSON = require 'season'
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
      enum: ["Project name", "Latest modification date", "Size"]
    showSubRepos:
      title: "Show sub-repositories"
      type: "boolean"
      default: false
    openInDevMode:
      title: "Open in development mode"
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
      devMode: atom.config.get('git-projects.openInDevMode')

  createGitProjectsViewView: (state) ->
    @gitProjectsView ?= new GitProjectsView()

  getGitProjects: (rootPath) ->
    if fs.existsSync(rootPath)
      gitProjects = fs.readdirSync(rootPath)
      for index, name of gitProjects
        projectPath = rootPath + name
        if fs.lstatSync(projectPath).isDirectory()
          if utils.isGitProject(projectPath)
            project = new Project(name, projectPath, false)
            data = @readProjectConfigFile(project)
            project = @updateProjectFromConfigFileData(data, project)
            @projects.push(project) if !project.ignored
            if atom.config.get('git-projects.showSubRepos')
              @getGitProjects(projectPath + path.sep)
          else @getGitProjects(projectPath + path.sep)

    return utils.sortBy(@projects)

  clearProjectsList: ->
    @projects = []

  readProjectConfigFile: (project) ->
    filepath = project.path + path.sep + ".git-project"
    data = {}
    data = CSON.readFileSync(filepath) if fs.existsSync(filepath)

  updateProjectFromConfigFileData: (data, project) ->
    return project unless data?
    project.title = data['title'] if data['title']?
    project.ignored = data['ignore'] if data['ignore']?
    project
