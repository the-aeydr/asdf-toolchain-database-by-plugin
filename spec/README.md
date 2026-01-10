# Alternative Specifications & Considerations

The approach of using ini files in the form of `http.ini` is not the only approach that was considered, but it was ultimately chosen as it enabled showing both a file system schema, as well as making use of a configuration file to store properties. Other considerations concerned how to represent the file-system database, and where this database should be stored. Within this section the following configuration considerations will be discussed:

- Multi-arch Version File - Use a single file to represent all platform-specific files of a release (`version.ini`)
- File per Platform - Use a configuration file per platform of a release (`http.ini`)
- Single File Properties - Use multiple files to represent each property of a platform release (`http_url`, `checksum`)
- Externalize Database from Plugin - Use a separate repository from the plugin for storing the files


For the purposes of this demonstrate, the `http.ini` file format was chosen over using a file per field (e.g. `checksum`, `curl.txt`, etc). 

## Multi-arch Version File

This model proposed a single file that contained all the platform specific entries of a release, which meant that the introduction of a new release version only required the addition of a single new file.

```ini
version = 3.11.0

[linux_arm64]
http_url=https://get.helm.sh/helm-v3.11.0-linux-arm64.tar.gz
sha256=57d36ff801ce8...
flags=--strip-components=1

[linux_amd64]
http_url=https://get.helm.sh/helm-v3.11.0-linux-amd64.tar.gz
sha256=3b4da33e5d4ea1....
flags=--strip-components=1
```

This meant that the read logic complexity within the plugin needed to be more capable of handling the files, and eventually we would still encounter the case of wanting to have files, such as in the case of PGP signatures for verifying that the checksums matched with what was expected.


## http.ini

This model proposed

```ini
http_url=https://get.helm.sh/helm-v3.11.0-linux-arm64.tar.gz
sha256=57d36ff801ce8c0201ce9917c5a2d3b4da33e5d4ea154320962c7d6fb13e1f2c
flags=--strip-components=1
```

This approach was chosen at it allowed demonstrating:

- Using the directory layout to perform lookups (`tools/{tool}/{version}/{platform}/{arch/`)
- Read objects from keys within the file system (`http.ini => { "http_url": "https://...", "sha256": "57d3..." }`)

## Single File Properties

This model proposes using the file system for representing, such that any property of an object, such as the checksum of a file, is represented as its own file. This would look like in practice a directory structure as laid out within `single_file/`:

```text
.
├── curl.txt
├── tar.txt
├── file.asc
├── file.sha256sum
└── file.sha256sum.asc
```

The above set of files can be described in detail as follows:

- `curl.txt` - The parameters to supply to `cURL` for downloading the release archive (e.g. `http_url`)
- `tar.txt` - The parameters to provide to `tar` for extracting the binary
- `file.sha256sum` - The parameters to supply to `cURL` for downloading the release archive (e.g. `http_url`)

> For demonstrating expansion of this pattern, `asc` files have been included which could be used for PGP verification

This was ultimately chosen against, as it would likely see overtime the number of files contained within the repository reaching a size that wouldn't be reasonable to download. If sourced as a single `archive`, this may work.

## Externalized Database

For simplicity, the `tools/` database was included within the same repository as the plugin, but for a production case it could be seen as worthwhile to encode all of these files in another git repository. This would remove the need to continuously update the plugin repositories for new versions to become available, and instead allow for the external git repository to be cloned, and continuously refreshed when new changes appear. This also enables the possibility of creating alternative plugins that switch the underlying git repository to another, allowing for an organization to mirror the toolchains to an alternative store.

Relying on the upstream for the list of "verified" binaries, without having to deal with the overhead.