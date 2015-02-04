fs = require 'fs'
path = require 'path'
utils = require '../lib/utils'
Project = require '../lib/models/project'

workspaceElement = null
projects = null
projectsSortedByName = null

describe "Utils", ->

  beforeEach ->
    workspaceElement = atom.views.getView(atom.workspace)
    waitsForPromise = atom.packages.activatePackage('git-projects')
    projects = [new Project("notification", "", false), new Project("settings-view", "", false), new Project("atom", "", false)]
    projectsSortedByName = [new Project("atom", "", false), new Project("notification", "", false), new Project("settings-view", "", false)]

  describe "sortBy", ->
    it "sorts by name when sortBy == 'Project name'", ->
      atom.config.set('git-projects.sortBy', 'Project name')
      expect(utils.sortBy(projects)).toEqual(projectsSortedByName)
