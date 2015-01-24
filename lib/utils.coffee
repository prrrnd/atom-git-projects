fs = require 'fs'
path = require 'path'

module.exports =
getHomeDir: ->
  process.env["HOME"] || process.env["HOMEPATH"] || process.env["USERPROFILE"]

isGitProject: (project) ->
  gitDir = project + path.sep + ".git"
  @isDir(project) && fs.existsSync(gitDir) && @isDir(gitDir)

isDir: (path) ->
  fs.lstatSync(path).isDirectory()

sortBy: (array) ->
  array.sort (a, b) ->
    if atom.config.get('git-projects.sortBy') is 'Project name'
      a['title'].toUpperCase() > b['title'].toUpperCase()
    else
      fs.statSync(a.path)['mtime'] < fs.statSync(b.path)['mtime']
