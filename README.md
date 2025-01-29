[link to repo](https://github.com/ISISComputingGroup/reusable-workflows)
# Repository for holding reusable github workflows and related files.
## Linters.yml
The linters.yml workflow file adds a linter workflow for python that runs a ruff check, ruff format check, and pyright on _changed_ files on a specified python version. This workflow is designed to be on pullrequest, but could also be ran at push etc.
The linters workflow takes the following arguements:
 - `compare-branch` - This arguement is required, and it expects a string telling it what branch to compare against (usually `origin/master` or `origin/main`).
 - `python-ver` - This argument is optional, it requires a string setting the python version to use, it defaults to `3.10`.
### Using the workflow.
To use the workflow its a simple as creating a new github action in the repository i.e. a .yml file in `repository/.github/workflows/` that contains a job to call the workflow:
```
name: Linter
on: [pull_request]
jobs:
  call-workflow:
    uses: ISISComputingGroup/reusable-workflows/.github/workflows/linters.yml@main
    with:
      compare-branch: origin/master
```
To set the python version rather than using the default just add `python-ver` to the `with:` in the same manner as `compare-branch`.

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

#### Local configuration: git hook

A git hook is available in the `.hooks` folder of this repository, which calls ruff on any modified python files on commit, and will prevent commiting if ruff checks fail.

The pre-commit hook assumes that you have checked out the `reusable-workflows` repository to `c:\instrument\dev\reusable-workflows`. To enable the hook globally on your machine, run:
```
git config --global core.hooksPath "/c/Instrument/dev/reusable-workflows/.hooks"
```

The git hook will respect the settings in repo-local `ruff.toml` files, and like the build server, will only check modified files. 

It will also respect any other pre-commit hooks defined in the repository.

Note that if you then need to explicitly bypass these checks (e.g. you are committing to an external repository that does not use our coding standards), you will then need to pass `--no-verify` to your `git commit` commands to disable git hooks.

#### Local configuration: convenience script

There is a script, `r.bat`, in `./scripts` that will invoke ruff for convenience. Like the git hook, it respects repo-local `ruff.toml` files.

After adding `c:\instrument\dev\reusable-workflows\scripts` to your `PATH`, it can be executed as:
```
r format --check
r format
r check
```

Unlike the git hook, this will check all files by default. You can pass the script an explicit list of files:
```
r format --check c:\path\to\some\file.py
```

### Pyright
The Pyright linter uses diff_cover and the [pyright diff-cover plugin](https://github.com/DiamondLightSource/pyright_diff_quality_plugin) to run pyright on files that have changed.

## sphinx.yml
This workflow exists for building sphinx documentation and publishing it to the github pages of the "caller" repo. 


### Using the workflow

to use, your caller sphinx.yml needs to look something like this: 

```yaml
name: sphinx
on: [push, workflow_call]
jobs:
  call_sphinx_builder:
    uses: ISISComputingGroup/reusable-workflows/.github/workflows/sphinx.yml@main
    secrets: inherit
```

You also need to give "write" permission for github actions, this is done for each repository in the repo settings on Github. 

To use with a different branch, use the `with` syntax to specify the branch name as `deploy-branch` ie. 

```yaml
name: sphinx
on: [push, workflow_call]
jobs:
  call_sphinx_builder:
    uses: ISISComputingGroup/reusable-workflows/.github/workflows/sphinx.yml@main
    secrets: inherit
    with:
      deploy-branch: "master"
```

This workflow requires a `pyproject.toml` file containing a `doc` optional dependency section, like so: 

```toml
... 
[project.optional-dependencies]
doc = [
    "sphinx", 
    "sphinx_rtd_theme", 
    "myst_parser",
]
```

Note that the above three are the bare minimum needed for this workflow. This is specified in the "caller" repo as the documentation for that repository may require more sphinx plugins etc. 

### Documentation structure
The documentation should be stored in `doc/` of the "caller" repo, which needs two files in the root (along with normal markdown files): 

(where `some-feature.md` and `another-feature.md` are located in `doc/`)

`index.rst`: 
```rst
Welcome to Example's documentation!
===================================

.. toctree::
   :maxdepth: 2
   :caption: Contents:

   some-feature.md
   another-feature.md
```
which forms the homepage of the doc site,

and 

`conf.py`: 

```python
project = 'Example'
copyright = 'workshop participant'
author = 'workshop participant'
release = '0.1'

# -- General configuration ---------------------------------------------------
# https://www.sphinx-doc.org/en/master/usage/configuration.html#general-configuration

extensions = ['myst_parser']

templates_path = ['_templates']
exclude_patterns = ['_build', 'Thumbs.db', '.DS_Store']

# -- Options for HTML output -------------------------------------------------
# https://www.sphinx-doc.org/en/master/usage/configuration.html#options-for-html-output

html_theme = 'sphinx_rtd_theme'
html_static_path = ['_static']
```

which is the sphinx configuration file.


