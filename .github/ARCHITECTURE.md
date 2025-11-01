# GitHub Configurations

This directory contains GitHub-related configurations. GitHub handles some of these files even when they are placed in the root of the project (such as `CONTRIBUTING.md` and `CODE_OF_CONDUCT.md`), but grouping them under `.github` helps reduce clutter at the root level. Feel free to place anything specifically related to GitHub inside this folder.

Configuration files within this folder typically follow the convention of UPPERCASE for documentation files, and lowercase for configuration files such as `dependabot.yml` or `stale.yml`.

Some of the most commonly used files in the `.github` folder:

* `CODE_OF_CONDUCT.md` → Guidelines for community engagement and expected behavior.
* `CONTRIBUTING.md` → Instructions on how to contribute to the repository.
* `PULL_REQUEST_TEMPLATE.md` → Template and guidance for submitting pull requests.
* `LICENSE.md` → Software license outlining what others can and can't do with the source code.
* `FUNDING.yml` → Configuration for financial support options.
* `SECURITY.md` → Instructions for responsibly reporting security vulnerabilities.
* `CODEOWNERS` → Rules for assigning reviewers to pull requests.
