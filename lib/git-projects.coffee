fs = require 'fs'
path = require 'path'
utils = require './utils'
settings = require './settings'
CSON = require 'season'
GitProjectsView = require './views/git-projects-view'
Project = require './models/project'
separator = "Separate paths with semicolons"

module.exports =
  config:
    rootPath:
      title: "Paths to folders containing project folders. #{separator}."
      type: "string"
      default: settings.getDefaultRootPath()
    ignoredPath:
      title: "Paths to folders that should be ignored. #{separator}."
      type: "string"
      default: ""
    ignoredPatterns:
      title: "Patterns that should be ignored (e.g.: node_modules). #{separator}."
      type: "string"
      default: "node_modules;.git"
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

  parsePathString: (str) ->
    if str
      paths = str.split(/\s*;\s*/g).map (_str) ->
        _str = _str.trim().replace /^~/g, utils.getHomeDir()
        if _str[-1..-1] isnt path.sep then _str + path.sep else _str

    new Set paths

  getGitProjects: (rootPath=settings.getDefaultRootPath(), ignoredPath="", ignoredPattern="") ->
    rootPaths = @parsePathString rootPath
    ignoredPaths = @parsePathString ignoredPath

    if ignoredPattern
      if Object::toString.call( ignoredPattern ) == "[object RegExp]"
        ignoredPatterns = ignoredPattern
      else
        patterns = ignoredPattern.split(/\s*;\s*/g).map (pattern) ->
          pattern.trim().replace /^~/g, utils.getHomeDir()
        ignoredPatterns = new RegExp patterns.join("|"), "g"

    rootPaths.forEach (_path) =>
      if (ignoredPatterns and ignoredPatterns.test(_path)) or
         ignoredPaths.has(_path) or
         !fs.existsSync(_path)
        return

      gitProjects = fs.readdirSync(_path)

      for _, name of gitProjects
        projectPath = _path + name

        if (!ignoredPatterns or !ignoredPatterns.test(_path)) and
           !ignoredPaths.has(projectPath + path.sep) and
           fs.lstatSync(projectPath).isDirectory()

          if utils.isGitProject(projectPath)
            project = new Project(name, projectPath, false)
            data = @readProjectConfigFile(project)
            project = @updateProjectFromConfigFileData(data, project)
            @projects.push(project) if !project.ignored
            if atom.config.get('git-projects.showSubRepos')
              @getGitProjects(projectPath, ignoredPath, ignoredPatterns)
          else @getGitProjects(projectPath, ignoredPath, ignoredPatterns)

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
