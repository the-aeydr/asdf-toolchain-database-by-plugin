# Plugins

Directory containing the list of asdf plugins, each contained within a dictionary by the plugin name (e.g. `asdf-plugin-{}`).

## Local Plugins

The plugins within this directory would be made available as Git Repositories hosted for installing using the `asdf plugin add <name> <url>` command. For the purposes of validating this concept, and creating the necessary testing scaffolding, these plugins are contained within a `plugins/` directory within this repository. These can be loaded into a local installation of `asdf` with symlinks, with the long-term preferred method for distribution being publishing these directories into their own git repositories.

For local development to enable one of the plugins (similar to `asdf plugin add ..`), you can run the following command from the root of the repository:

```bash
name="foobar" # Fill in with directory name in plugins/
ln -s $(PWD)/plugins/$name ~/.asdf/plugins/$name
```

These plugin installations can later be removed by running the `asdf plugin remove <name>`. For the above, it would be `asdf plugin remove foobar`.
