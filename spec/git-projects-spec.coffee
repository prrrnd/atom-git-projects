{$} = require 'atom-space-pen-views'
GitProjects = require '../lib/git-projects'
utils = require '../lib/utils'
workspaceElement = null
fs = require 'fs'
path = require 'path'

describe "GitProjects", ->

  beforeEach ->
    workspaceElement = atom.views.getView(atom.workspace)
    waitsForPromise = atom.packages.activatePackage('git-projects')

  describe "when the git-projects:toggle event is triggered", ->
    it "Toggles the view containing the list of projects", ->
      atom.commands.dispatch workspaceElement, 'git-projects:toggle'
      expect($(workspaceElement).find('.git-projects')).toExist()
      setTimeout( ->
        atom.commands.dispatch workspaceElement, 'git-projects:toggle'
        expect($(workspaceElement).find('.git-projects')).not.toExist()
      , 0)

  describe "findGitRepos", ->
    it "should return an array", ->
      expect(GitProjects.findGitRepos()).toBeArray
      expect(GitProjects.findGitRepos("~/workspace/;~/workspace; ~/workspace/fake")).toBeArray

    it "should not contain any of the ignored patterns", ->
      projects = GitProjects.findGitRepos("~/workspace/;~/workspace; ~/workspace/fake")
      projects.forEach (project) ->
        expect(project.path).not.toMatch( /node_modules|\.git/g )

    it "should not contain any of the ignored paths", ->
      projects = GitProjects.findGitRepos("~/workspace/;~/workspace; ~/workspace/fake")
      projects.forEach (project) ->
        expect(project.path).not.toMatch( /\/workspace\/www/g )
