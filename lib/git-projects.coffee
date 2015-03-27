$ = require 'jquery'
fs = require 'fs-plus'
path = require 'path'
utils = require './utils'

Project = require './models/project'
ProjectsListView = require './views/projects-list-view'

module.exports =
  config:
    rootPath:
      title: "Root paths"
      description: "Paths to folders containing Git repositories, separated by semicolons."
      type: "string"
      default: fs.absolute(fs.getHomeDirectory() + "#{path.sep}repos")
    ignoredPath:
      title: "Ignored paths"
      description: "Paths to folders that should be ignored, separated by semicolons."
      type: "string"
      default: ""
    ignoredPatterns:
      title: "Ignored patterns"
      description: "Patterns that should be ignored (e.g.: node_modules), separated by semicolons."
      type: "string"
      default: "node_modules;\\.git"
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
    notificationsEnabled:
      title: "Notifications enabled"
      type: "boolean"
      default: true
    showGitInfo:
      title: "Show repositories status"
      description: "Display the branch and a status icon in the list of projects"
      type: "boolean"
      default: true


  projects: []
  view: null

  activate: (state) ->
    @checkForUpdates()
    atom.commands.add 'atom-workspace',
      'git-projects:toggle': =>
        @createView().toggle(@)


  # Checks for updates by sending an ajax request to the latest package.json
  # hosted on Github.
  checkForUpdates: ->
    packageVersion = require("../package.json").version
    $.ajax({
      url: 'https://raw.githubusercontent.com/prrrnd/atom-git-projects/master/package.json',
      success: (data) ->
        latest = JSON.parse(data).version
        if(packageVersion != latest)
          if atom.config.get('git-projects.notificationsEnabled')
            atom.notifications.addInfo("<strong>Git projects</strong><br>Version #{latest} available!", dismissable: true)
    })


  # Opens a project. Supports for dev mode via package settings
  #
  # project - The {Project} to open.
  openProject: (project) ->
    atom.open options =
      pathsToOpen: [project.path]
      devMode: atom.config.get('git-projects.openInDevMode')


  # Creates an instance of the list view
  createView: ->
    @view ?= new ProjectsListView()


  # Clears the projects array
  clearProjectsList: ->
    @projects = []


  # Finds all the git repositories recursively from the given root path(s)
  findGitRepos: (root = atom.config.get('git-projects.rootPath')) ->
    rootPaths = utils.parsePathString(root)
    return @projects unless rootPaths?

    ignoredPattern = atom.config.get('git-projects.ignoredPatterns')
    ignoredPaths = utils.parsePathString(atom.config.get('git-projects.ignoredPath'))

    if ignoredPattern
      if Object::toString.call(ignoredPattern) == "[object RegExp]"
        ignoredPatterns = ignoredPattern
      else
        patterns = ignoredPattern.split(/\s*;\s*/g)
        ignoredPatterns = new RegExp patterns.join("|"), "g"

    rootPaths.forEach (_path) =>
      if (ignoredPatterns and ignoredPatterns.test(_path)) or
         (ignoredPaths and ignoredPaths.has(_path)) or
         !fs.existsSync(_path)
        return

      for _, name of fs.readdirSync(_path)
        projectPath = _path + path.sep + name
        if (!ignoredPatterns or !ignoredPatterns.test(_path)) and
           !ignoredPaths.has(projectPath + path.sep) and
           fs.isDirectorySync(projectPath)

          if utils.isRepositorySync(projectPath)
            project = new Project(name, projectPath, "icon-repo", false)
            if !project.ignored
              @projects.push(project)
              if atom.config.get('git-projects.showSubRepos')
                @findGitRepos(projectPath)
          else @findGitRepos(projectPath)

    return utils.sortBy(@projects)
