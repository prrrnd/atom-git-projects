fs = require 'fs'
path = require 'path'
utils = require './utils'
settings = require './settings'
CSON = require 'season'
GitProjectsView = require './views/git-projects-view'
Project = require './models/project'

module.exports =
  config:
    rootPaths:
      title: "Paths to folders containing project folders. Separate paths with semicolons."
      type: "string"
      default: settings.getDefaultRootPaths()
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

  getGitProjects: (rootPaths) ->
    rootPaths = rootPaths.split(/\s*;\s*/g)
    for rootPath in rootPaths when fs.existsSync(rootPath)
      rootPath = rootPath + path.sep if rootPath[-1..-1] isnt path.sep
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
              @getGitProjects(projectPath)
          else @getGitProjects(projectPath)

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
