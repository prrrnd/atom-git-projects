path = require 'path'
utils = require './utils'

module.exports =
getDefaultRootPaths: ->
  path.normalize(utils.getHomeDir() + path.sep + "repos")
