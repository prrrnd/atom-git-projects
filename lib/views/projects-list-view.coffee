{$, $$, SelectListView, View} = require 'atom-space-pen-views'
fs = require 'fs-plus'
path = require 'path'
Project = require '../models/project'

module.exports =
class ProjectsListView extends SelectListView
  controller: null

  activate: ->
    new ProjectsListView

  initialize: (serializeState) ->
    super
    @addClass('git-projects')

  getFilterKey: ->
    'title'

  getFilterQuery: ->
    @filterEditorView.getText()

  cancelled: ->
    @hide()

  confirmed: (project) ->
    @controller.openProject(project)
    @cancel()

  getEmptyMessage: (itemCount, filteredItemCount) =>
    msg = "No repositories found in '#{atom.config.get('git-projects.rootPath')}'"
    query = @getFilterQuery()
    return "#{msg} for '#{query}'" if !filteredItemCount && query.length
    return msg unless itemCount
    return super

  toggle: (controller) ->
    @controller = controller
    if @panel?.isVisible()
      @hide()
    else
      @show()

  hide: ->
    @panel?.hide()
    @controller.clearProjectsList()

  show: ->
    @panel ?= atom.workspace.addModalPanel(item: this)
    @loading.text "Looking for repositories ..."
    @loadingArea.show()
    @panel.show()
    setTimeout( =>
      @setItems(@controller.findGitRepos())
      @focusFilterEditor()
    , 0)

  viewForItem: (project) ->
    $$ ->
      @li class: 'two-lines', =>
        @div class: 'status status-added'
        @div class: 'primary-line icon ' + project.icon, =>
          @span project.title
          if atom.config.get('git-projects.showGitInfo')
            @span " (#{project.branch()})"
            if project.isDirty()
              @span class: 'status status-modified icon icon-diff-modified'
        @div class: 'secondary-line no-icon', =>
          @span project.path
