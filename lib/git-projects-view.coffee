{$, $$, SelectListView, View} = require 'atom-space-pen-views'
fs = require 'fs'
path = require 'path'
projects = []
module.exports =
class GitProjectsView extends SelectListView
  gitProjects: null

  activate: ->
    new GitProjectsView

  initialize: (serializeState) ->
    super
    @addClass('git-projects')

  serialize: ->

  getFilterKey: ->
    'title'

  getFilterQuery: ->
    @filterEditorView.getText()

  cancelled: ->
    @hide()

  confirmed: (project) ->
    @gitProjects.openProject(project)
    @cancel()

  getEmptyMessage: (itemCount, filteredItemCount) =>
    if not itemCount
      'No Git projects found in ' + atom.config.get('git-projects.rootPath')
    else
      super

  toggle: (gitProjects) ->
    @gitProjects = gitProjects
    if @panel?.isVisible()
      @hide()
    else
      @show()

  hide: ->
    @panel?.hide()

  show: ->
    @panel ?= atom.workspace.addModalPanel(item: this)
    @panel.show()
    rootPath = atom.config.get('git-projects.rootPath') + path.sep
    projects = []
    @setItems(@getGitProjects(rootPath))
    @focusFilterEditor()

  viewForItem: ({title, path}) ->
    $$ ->
      @li class: 'two-lines', =>
        @div class: 'primary-line', =>
          @span title
        @div class: 'secondary-line', =>
          @span path

  getGitProjects: (rootPath) ->
    if fs.existsSync(rootPath)
      gitProjects = fs.readdirSync(rootPath)
      for index, project of gitProjects
        projectPath = rootPath + project
        if @isGitProject(projectPath)
          projects.push({title: project, path: projectPath})
        else if fs.lstatSync(projectPath).isDirectory()
          @getGitProjects(projectPath + path.sep)

    return @sortBy(projects)

  isGitProject: (project) ->
    gitDir = project + path.sep + ".git"
    fs.lstatSync(project).isDirectory() && fs.existsSync(gitDir) && fs.lstatSync(gitDir).isDirectory()

  sortBy: (projects) ->
    projects.sort (a, b) ->
      a['title'].toUpperCase() > b['title'].toUpperCase()
