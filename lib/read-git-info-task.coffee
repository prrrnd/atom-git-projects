git = require 'git-utils'

readGitInfo = (path) ->
  repository = git.open path
  result =
    branch: repository.getShortHead()
    dirty: Object.keys(repository.getStatus()).length != 0

  repository.release()
  return result

module.exports = (path) ->
  # Indicates that this task will be async.
  # Call the `callback` to finish the task
  callback = @async()
  emit('result', readGitInfo(path))
  callback()
