{$} = require 'atom-space-pen-views'
GitProjects = require '../lib/git-projects'
workspaceElement = null
fs = require 'fs'
path = require 'path'

describe "GitProjects", ->

  beforeEach ->
    workspaceElement = atom.views.getView(atom.workspace)
    waitsForPromise = atom.packages.activatePackage('git-projects')

  describe "when the git-projects:toggle event is triggered", ->
    it "Shows the view containing the list of projects", ->
      atom.commands.dispatch workspaceElement, 'git-projects:toggle'
      expect($(workspaceElement).find('.git-projects')).toExist()

  describe "getGitProjects", ->
    it "should return an array", ->
        atom.config.set('git-projects.showSubRepos', true)
        expect(GitProjects.getGitProjects("~/workspace/;~/workspace; ~/workspace/fake", "~/workspace/www", "node_modules;.git")).toBeArray
