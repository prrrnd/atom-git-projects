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

  describe "parsePathString", ->
    it "should be a function",
      expect(GitProjects.parsePathString).toBeFunction

    it "should only take strings in parameter", ->
      wrapper = (any) ->
        return GitProjects.parsePathString.bind this, any

      expect(wrapper "").not.toThrow
      expect(wrapper 1).toThrow
      expect(wrapper null).toThrow

    it "should return a Set", ->
      expect(GitProjects.parsePathString("")).toEqual(new Set)
      expect(GitProjects.parsePathString("path").size).toBe(1)
      expect(GitProjects.parsePathString("path; another_path").size).toBe(2)
      expect(GitProjects.parsePathString("same_path; same_path").size).toBe(1)


  describe "getGitProjects", ->

    it "should return an array", ->
      atom.config.set('git-projects.showSubRepos', false)
      expect(GitProjects.getGitProjects()).toEqual([])
      expect(GitProjects.getGitProjects("~/workspace/;~/workspace; ~/workspace/fake", "~/workspace/www", "node_modules;.git")).toBeArray

    it "should work with sub directories", ->
      atom.config.set('git-projects.showSubRepos', true)
      expect(GitProjects.getGitProjects("~/workspace/;~/workspace; ~/workspace/fake", "~/workspace/www", "node_modules;.git")).toBeArray

    it "should not contain any of the ignored patterns", ->
      projects = GitProjects.getGitProjects("~/workspace/;~/workspace; ~/workspace/fake", "~/workspace/www", "node_modules;.git")
      projects.forEach (project) ->
        expect(project.path).not.toMatch( /node_modules|\.git/g )

    it "should not contain any of the ignored paths", ->
      projects = GitProjects.getGitProjects("~/workspace/;~/workspace; ~/workspace/fake", "~/workspace/www", "node_modules;.git")
      projects.forEach (project) ->
        expect(project.path).not.toMatch( /\/workspace\/www/g )
