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
    projects = [new Project("notification"), new Project("settings-view"), new Project("atom")]
    projectsSortedByName = [new Project("atom"), new Project("notification"), new Project("settings-view")]

  describe "sortBy", ->
    it "sorts by name when sortBy == 'Project name'", ->
      expect(utils.sortBy('Project name', projects)).toEqual(projectsSortedByName)

  describe "parsePathString", ->
    it "should be a function",
      expect(utils.parsePathString).toBeFunction

    it "should only take strings in parameter", ->
      wrapper = (any) ->
        return utils.parsePathString.bind this, any

      expect(wrapper "").not.toThrow
      expect(wrapper 1).toThrow
      expect(wrapper null).toThrow

    it "should return a Set", ->
      expect(utils.parsePathString("")).toEqual(new Set(["."]))
      expect(utils.parsePathString("path").size).toBe(1)
      expect(utils.parsePathString("path; another_path").size).toBe(2)
      expect(utils.parsePathString("same_path; same_path").size).toBe(1)
      expect(utils.parsePathString("~").size).toBe(1)

  describe "isRepositorySync", ->
    it "should be a function",
      expect(utils.isRepositorySync).toBeFunction

    it "should return false if no params", ->
      expect(utils.isRepositorySync()).toBe(false)
