fs = require 'fs-plus'
path = require 'path'
git = require 'git-utils'

sorts = new Map
sorts.set 'Project name', (a, b) ->
  a.title.toUpperCase() > b.title.toUpperCase()
sorts.set 'Latest modification date', (a, b) ->
  fs.statSync(a.path)['mtime'] < fs.statSync(b.path)['mtime']
sorts.set 'Size', (a, b) ->
  fs.statSync(a.path)['size'] < fs.statSync(b.path)['size']

module.exports =

# Returns true if the passed dir is a Git repo
isRepositorySync: (dir) ->
  return dir? and git.open(dir)?


# Returns a sorted {Array} of projects based on the package settings
# array - {Array} of {Project}s to sort
sortBy: (array) ->
  array.sort sorts.get atom.config.get('git-projects.sortBy')


# Returns a {Set} of paths
# str - {String} containing paths separated by semicolons
parsePathString: (str) ->
  return null unless str?

  paths = str.toString().split(/\s*;\s*/g).map (_str) ->
    _str = fs.normalize(_str)

  new Set(paths)
