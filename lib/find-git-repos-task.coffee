fs = require 'fs-plus'
path = require 'path'
utils = require './utils'

Project = require './models/project'

sortByFn = (_sortKey) ->
  return (array) ->
    utils.sortBy(_sortKey, array)

shouldIgnorePathFn = (_ignoredPath, _ignoredPatterns) ->
  # Determines if a path should be ignored based on the package settings
  # Returns true if the given _path should be ignored, false otherwise
  #
  # _path - {String} the path to test
  return (_path) ->
    ignoredPaths = utils.parsePathString(_ignoredPath)
    ignoredPattern = new RegExp((_ignoredPatterns || "").split(/\s*;\s*/g).join("|"), "g")
    return true if ignoredPattern.test(_path)
    return ignoredPaths and ignoredPaths.has(_path)


# Finds all the git repositories recursively from the given root path(s)
#
# root - {String} the string of root paths to search from
# maxDepth - {Number} max folder depth
# sortBy - {Function} the configured `sortBy` function
# shouldIgnorePath - {Function} the configured `shouldIgnorePath` function
findGitRepos = (root, maxDepth, sortBy, shouldIgnorePath, cb) ->
  projects = []
  pathsChecked = 0
  rootPaths = utils.parsePathString(root)

  rootPaths.forEach (rootPath) ->

    sendCallback = ->
      if ++pathsChecked == rootPaths.size
        cb(sortBy(projects))

    return sendCallback() if shouldIgnorePath(rootPath)

    rootDepth = rootPath.split(path.sep).length

    fs.traverseTree(rootPath, (->), (_dir) ->
      return false if shouldIgnorePath(_dir)
      if utils.isRepositorySync(_dir)
        project = new Project(_dir)
        unless project.ignored
          projects.push(project)
        return false

      dirDepth = _dir.split(path.sep).length
      return rootDepth + maxDepth > dirDepth
    , ->
      sendCallback()
    )


module.exports = (rootPaths, config) ->
  # Indicates that this task will be async.
  # Call the `callback` to finish the task
  callback = @async()

  maxDepth = config.maxDepth
  sortBy = sortByFn(config.sortBy)
  shouldIgnorePath = shouldIgnorePathFn(config.ignoredPath, config.ignoredPatterns)

  findGitRepos rootPaths, maxDepth, sortBy, shouldIgnorePath, (projects) ->
    emit('found-repos', projects)
    callback()
