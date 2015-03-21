{$, $$, SelectListView, View} = require 'atom-space-pen-views'
fs = require 'fs'
path = require 'path'
Project = require '../models/project'

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
    msg = "No Git projects found in '#{atom.config.get('git-projects.rootPath')}'"
    query = @getFilterQuery()
    return "#{msg} for '#{query}'" if !filteredItemCount && query.length
    return msg unless itemCount
    return super

  toggle: (gitProjects) ->
    @gitProjects = gitProjects
    if @panel?.isVisible()
      @hide()
    else
      @show()

  hide: ->
    @panel?.hide()
    @gitProjects.clearProjectsList()

  show: ->
    @panel ?= atom.workspace.addModalPanel(item: this)
    @panel.show()
    rootPath = atom.config.get('git-projects.rootPath')
    ignoredPath = atom.config.get('git-projects.ignoredPath')
    ignoredPatterns = atom.config.get('git-projects.ignoredPatterns')
    @setItems(@gitProjects.getGitProjects(rootPath, ignoredPath, ignoredPatterns))
    @focusFilterEditor()

  viewForItem: (project) ->
    $$ ->
      @li class: 'two-lines', =>
        @div class: 'status status-added'
        @div class: 'primary-line icon ' + project.icon, =>
          @span project.title
        @div class: 'secondary-line no-icon', =>
          @span project.path
