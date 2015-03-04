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
  sortfunc = switch atom.config.get('git-projects.sortBy')
    when 'Project name' then (a, b) -> 
      a.title.toUpperCase() > b.title.toUpperCase()
    when 'Latest modification date' then (a, b) -> 
      fs.statSync(a.path)['mtime'] < fs.statSync(b.path)['mtime']
    when 'Size' then (a, b) -> 
      fs.statSync(a.path)['size'] < fs.statSync(b.path)['size']
  array.sort sortfunc
