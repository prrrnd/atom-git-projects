{$, $$, SelectListView, View} = require 'atom-space-pen-views'
fs = require 'fs-plus'
path = require 'path'
Project = require '../models/project'

module.exports =
class ProjectsListView extends SelectListView
  controller: null
  cachedViews: new Map

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

  show: ->
    @panel ?= atom.workspace.addModalPanel(item: this)
    @loading.text "Looking for repositories ..."
    @loadingArea.show()
    @panel.show()
    # Show the cached projects right away
    @cachedProjects = @controller.projects
    @setItems(@cachedProjects) if @cachedProjects?
    @focusFilterEditor()
    # Then show the refreshed projects
    setImmediate => @refreshItems()

  refreshItems: ->
    @cachedViews.clear()
    @controller.findGitRepos null, (repos) =>
      projectMap = {}
      @cachedProjects?.forEach (project) ->
        projectMap[project.path] = project

      # Copy some properties from the cached objects
      # But mark the object as stale so they are refreshed
      repos.map (repo) ->
        project = projectMap[repo.path]
        return repo unless project?
        repo.branch = project.branch
        repo.dirty = project.dirty
        repo.setStale(true)
        return repo

      @setItems(repos)

  viewForItem: (project) ->
    if cachedView = @cachedViews.get(project) then return cachedView
    view = $$ ->
      @li class: 'two-lines', =>
        @div class: 'status status-added'
        @div class: 'primary-line icon ' + project.icon, =>
          @span project.title
        @div class: 'secondary-line no-icon', =>
          @span project.path
    if atom.config.get('git-projects.showGitInfo')
      createdSubview = null
      subview = ->
        createdSubview = $$ ->
          @span " (#{project.branch})"
          if project.dirty
            @span class: 'status status-modified icon icon-diff-modified'
        view.find('.primary-line').append(createdSubview)

      if project.hasGitInfo() then subview()
      if not project.hasGitInfo() or project.isStale()
        project.readGitInfo ->
          createdSubview?.remove()
          subview()

    @cachedViews.set(project, view)
    return view
