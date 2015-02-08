[![Build Status](https://travis-ci.org/prrrnd/atom-git-projects.svg?branch=master)](https://travis-ci.org/prrrnd/atom-git-projects)

## Git projects

_Git projects_ is a package for Atom, which allows you to quickly list and open your local git repositories.

[![Git projects](capture.gif)](https://atom.io/packages/git-projects)

### Installation

Simply run the following command:
```sh
apm install git-projects
```

Or find the package in **Atom** &rarr; **Settings** &rarr; **Install** and search for "**git-projects**"

### Usage

Press `ctrl + alt + o` or type **Git Projects** in the Command Palette.

### Settings

| Key              | Default value    | Possible values                                        |
|------------------|------------------|--------------------------------------------------------|
| `rootPath`       | `~/`             | Any path to a directory                                |
| `sortBy`         | `"Project name"` | `"Project name"`, `"Last modification date"`, `"Size"` |
| `showSubRepos`   | `false`          | `true`, `false`                                        |
| `openInDevMode`  | `false`          | `true`, `false`                                        |

### Project-specific configuration

_Git projects_ will read the content of any `.git-project` file located at the root of your Git repository.
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

More options will be available in the future.

### Contributing

1. Fork it ( https://github.com/prrrnd/atom-git-projects/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

### License

Released under the [MIT License](http://www.opensource.org/licenses/MIT).
