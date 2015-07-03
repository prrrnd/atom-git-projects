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

cmp = (sort) ->
  return (a, b) ->
    return if sort(a, b) then 1 else -1

module.exports =

# Returns true if the passed dir is a Git repo
isRepositorySync: (dir) ->
  return dir? and fs.existsSync(path.join(dir,'.git'))


# Returns a sorted {Array} of projects based on the package settings
# sortKey - {String} the config value to sort by
# array - {Array} of {Project}s to sort
sortBy: (sortKey, array) ->
  array.sort cmp(sorts.get(sortKey))


# Returns a {Set} of paths
# str - {String} containing paths separated by semicolons
parsePathString: (str) ->
  return null unless str?

  paths = str.toString().split(/\s*;\s*/g).map (_str) ->
    _str = fs.normalize(_str)

  new Set(paths)
