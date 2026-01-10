# Single ASDF Plugin as a package database for toolchains

This is a companion repository for the written article 'ASDF, Toolchains and a Single Plugin as Package Database', in which this repository demonstrates examples of one such plugin, known as `toolchains`, which can be used as the sole plugin for any number of supported toolchains. ASDF Plugins typically work by querying APIs for a list of recent releases, downloading and installing from these artifact stores. This plugin precomputes the list of available toolchain versions, with the URL to retrieve, and any checksum or package specific functions.

This plugin is only made available within the demonstration within the repository, as this repository does not conform to the asdf plugin git repository pattern, and wouldn't easily be installable using the `asdf plugin add <tool> <git-repo>` command. This instead relies on symlinks for performing local experiment with the ASDF plugin, allowing for use like so:

```bash
ln -s $(PWD)/plugins/toolchains ~/.asdf/plugins/terraform # equivalent to: asdf plugin add terraform https://...
ln -s $(PWD)/plugins/toolchains ~/.asdf/plugins/helm # equivalent to: asdf plugin add helm https://...

asdf install terraform latest
asdf install helm latest
```

## Getting Started

For working with the repository, this will be making requests to GitHub (& other) servers for unauthenticated downloading of artifacts, for which excessive use may encounter rate limits or connectivity issues. For simplicity, both a GitPod and Codespaces container are included with the repository, should you be familiar with those Developer Platform as a Service (DPaaS).

If you are working locally, you will need to ensure that the following tools are installed:

- [make](https://www.gnu.org/software/make/)
- [sha256sum](https://linux.die.net/man/1/sha256sum)

This repository uses `make` as an runner & interface for the asdf commands. It is recommended when entering the repository to run `make help` to see a list of available commands, and the related documentation.

## Installing Toolchains

The plugin within this repository locally is symlinked into the plugins directory, but in a release scenario would be a git repository cloned using `asdf plugin add <name> <https://>`. As the single repository would contain toolchain entries for multiple tools, it would use the same URL for multiple toolchains. Using the name of the plugin (`terraform`, `helm`, etc) to determine which tool is being worked with. An example of this is below:

```bash
PLUGIN_URL=https://...
asdf plugin add terraform $PLUGIN_URL
asdf plugin add helm $PLUGIN_URL
```

When working with a `.tool-versions` configuration file like below:

```text
crane 0.13.0
helm 3.10.2
terraform 1.3.5
```

The plugin would lookup within the plugins `tools/` directory, using a file system database, using the lookup schema of:

```bash
tools/{tool}/{version}/{platform}/{arch}/...
```

In the above case, these properties are:

- `tool` - The name of the tool we are working with, set by the name given to `asdf plugin add <name> <url>`
- `version` - The version of the tool to install. This version must be a directory within `tools/{tool}/`
- `platform` - The platform the toolchain will be installed within (linux/darwin/windows). This platform must be a directory within `tools/{tool}/{platform}`
- `arch` - The architecture the toolchain will be installed within (arm64/amd64/...). This platform must be a directory within `tools/{tool}/{platform}`

Within the toolchain directory will exist configuration file(s) that are. For the purposes of this example, only a `http.ini` file exists for which the URL, SHA256 sum and any additional flags to pass to either `zip` or `tar` will be provided. 

### Add a new toolchain 

When a new version of a toolchain, like `terraform` is released and been reviewed, it can be added as a new entry within the file system database. This would see the introduction of a new `http.ini` for each supported platform and architecture,  within the toolchain directory. For adding the new version `1.3.8` of `terraform`, this would mean an update to the current directory structure like so:

```text
.
├── ...
└── terraform
    ├── 1.3.5
    ├── 1.3.6
    ├── 1.3.7
    └── 1.3.8 <-- Newly added directory
```

These directories would contain the `http.ini` files, organized by `{platform}/{arch}` for each of the target platforms. The `http.ini` files would contain where to download the release from, along with any special considerations such as `sha256` sum, or flags for extracting the binaries from the toolchain set. When this verison is installed, the plugin will look within the `tools/` directory based on the host machine. This would look like so:

```text
tools/{tool}/{version}/{platform}/{arch}/http.ini
tools/terraform/1.3.8/linux/amd64/http.ini
```

The resultant path

```ini
http_url=https://releases.hashicorp.com/terraform/1.3.8/terraform_1.3.8_linux_amd64.zip
sha256=b8cf184...
```

> The `http.ini` isn't the only possible format for these toolchain files. Within the `spec/` directory are other considerations and ideas on this

### Adding a new toolchain

When a new toolchain is being configured within the plugin, it would see the introduction of a new directory within `tools/`. Similar to the addition of a new version, it'd see the addition of a new directory under `tools`, which would then follow the same path as adding a new version.

As an example, to include the toolchain `jq` into the set of managed toolchains with the pre-existing set of:

```text
.
├── crane
├── helm
└── terraform
```

It would see the addition of the directory `jq` (`tools/jq`), along with a set of `http.ini` files for the first version to be configured within the system:

```text
.
├── crane
├── jq
├── helm
└── terraform
```

Then the `http.ini` files (grouped by platform and architecture) can be included from the below:

```text
.
├── crane
│   ├── 0.12.0
│   └── 0.13.0
├── jq
│   ├── 1.5
│   └── 1.6
├── helm
│   ├── 3.10.0
│   ├── 3.10.1
│   ├── 3.10.2
│   ├── 3.10.3
│   └── 3.11.0
└── terraform
    ├── 1.3.5
    ├── 1.3.6
    └── 1.3.7
```

## Using entry 

```text
.
├── crane
├── jq
├── helm
└── terraform
```

```text
.
├── crane
│   ├── 0.12.0
│   └── 0.13.0
├── jq
│   ├── 1.5
│   └── 1.6
├── helm
│   ├── 3.10.0
│   ├── 3.10.1
│   ├── 3.10.2
│   ├── 3.10.3
│   └── 3.11.0
└── terraform
    ├── 1.3.5
    ├── 1.3.6
    └── 1.3.7
```

Within the current specification, it'd be:

```ini
http_url=https://get.helm.sh/helm-v3.11.0-linux-arm64.tar.gz
sha256=57d36ff801ce8c0201ce9917c5a2d3b4da33e5d4ea154320962c7d6fb13e1f2c
flags=--strip-components=1
```
