path = require 'path'
utils = require './utils'

module.exports =
getDefaultRootPath: ->
  path.normalize(utils.getHomeDir() + path.sep + "repos")
