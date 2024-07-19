# Repository for holding reusable github workflows and related files.
## Linters.yml
The linters.yml workflow file adds a linter workflow for python that runs a ruff check, ruff format check, and pyright on _changed_ files on a specified python version. This workflow is designed to be on pullrequest, but could also be ran at push etc.
The linters workflow takes the following arguements:
 - compare-branch - This arguement is required, and it expects a string telling it what branch to compare against (usually `origin/master` or `origin/main`).
 - python-ver - This argument is optional, it requires a string setting the python version to use, it defaults to `3.10`.
### Ruff
The Ruff linter checks for a local `ruff.toml` in the root of the repository, if it does not find one it fetches the default defined in this repository. It then runs a git-diff to get a list of changed files that it runs `ruff check` and `ruff format --check` on.
#### ruff.toml
The `ruff.toml` file used by default uses the following linter settings:
Line length of 100, indent width of 4.
|Code| Explanation|
|:---:|------------|
|N | Pep8 style naming conventions|
|I | ISort import sorting|
|E | Pycodestyle |
|F | Pyflakes |
|ANN | flake8-annotations |

In future we may use `D | pydocstyle` however at this time this causes so many errors it will likely just be ignored, so this may be added in future after some work has been done to address the volume of missing doc-strings.

We also ignore the following  rules on test files as they should have self-documenting names so should not need comments to document them, but may be longer than 100 characters, or contain unusual capitalisation:
|Code| Explanation|
|:---:|------------|
|N802 | Function names shoud be lowercase |
|D100 | Missing docstring in public module |
|D101 | Missing docstring in public class |
|D102 | Missing docstring in public method |
|E501 | Line too long. |

### Pyright
The Pyright linter uses diff_cover and the [pyright diff-cover plugin](https://github.com/DiamondLightSource/pyright_diff_quality_plugin) to run pyright on files that have changed.
