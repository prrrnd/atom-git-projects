[![Build Status](https://travis-ci.org/prrrnd/atom-git-projects.svg?branch=master)](https://travis-ci.org/prrrnd/atom-git-projects)

# Git projects

_Git projects_ is a package for Atom, which allows you to quickly list and open your local git repositories.

[![Git projects](https://github.com/prrrnd/atom-git-projects/raw/master/capture.gif)](https://atom.io/packages/git-projects)

## Table of Contents
  * [Installation](#installation)
  * [Usage](#usage)
  * [Settings](#settings)
  * [Project-specific configuration](#project-specific-configuration)
  * [Known issues](#known-issues)
  * [Other](#other)


## Installation <a id="installation"></a>

Simply run the following command:
```sh
apm install git-projects
```

Or find the package in **Atom** &rarr; **Settings** &rarr; **Install** and search for "**git-projects**"

## Usage <a id="usage"></a>

Press `ctrl + alt + o` or type **Git Projects** in the Command Palette.

## Settings <a id="settings"></a>

| Key                     | Default value      | Possible values                                            |
|-------------------------|--------------------|------------------------------------------------------------|
| `rootPath`              | `~/repos`          | One or more directories containing projects, sep. by `;`   |
| `ignoredPath`           | ` `                | One or more directories containing projects, sep. by `;`   |
| `ignoredPatterns`       | `node_modules;.git`| One or more patterns to ignore, sep. by `;`                |
| `sortBy`                | `"Project name"`   | `"Project name"`, `"Last modification date"`, `"Size"`     |
| `openInDevMode`         | `false`            | `true`, `false`                                            |
| `notificationsEnabled`  | `true`             | `true`, `false`                                            |
| `showGitInfo`           | `true`             | `true`, `false`                                            |
| `maxDepth`              | `5`                | Max number of directories to traverse from root            |

## Project-specific configuration  <a id="project-specific-configuration"></a>

_Git projects_ will read the content of any `.git-project` file located at the root of your Git repository (project).
You can set a custom title for any project that will be shown in the list view.
Here is an example:
```json
{
  "title": "Project Title"
}
```

If you don't want a project to be listed, add a `.git-project` file at its root with the following content:
```json
{
  "ignored": true
}
```

The project icon can also be customized.
```json
{
  "title": "Custom icon",
  "icon": "icon-file-text"
}
```

## Known issues <a id="known-issues"></a>

- Windows/linux users and [git-utils](https://github.com/atom/git-utils/issues)

## Other <a id="other"></a>

You can follow me on [Twitter](https://twitter.com/prrrnd)
