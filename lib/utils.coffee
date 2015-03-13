fs = require 'fs'
path = require 'path'

sorts = new Map
sorts.set 'Project name', (a, b) ->
  a.title.toUpperCase() > b.title.toUpperCase()
sorts.set 'Latest modification date', (a, b) ->
  fs.statSync(a.path)['mtime'] < fs.statSync(b.path)['mtime']
sorts.set 'Size', (a, b) ->
  fs.statSync(a.path)['size'] < fs.statSync(b.path)['size']

module.exports =
getHomeDir: ->
  process.env["HOME"] || process.env["HOMEPATH"] || process.env["USERPROFILE"]

isGitProject: (project) ->
  gitDir = project + path.sep + ".git"
  @isDir(project) && fs.existsSync(gitDir) && @isDir(gitDir)

isDir: (path) ->
  fs.lstatSync(path).isDirectory()

sortBy: (array) ->
  array.sort sorts.get atom.config.get('git-projects.sortBy')
