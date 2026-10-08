# peapod

peapod points a client repo at an unreleased copy of the Shapeshift library, in a work tree with its own `node_modules`.

## Install

```sh
curl -fsSL https://raw.githubusercontent.com/Eventyret/peapod-dist/main/install.sh | bash
```

It installs to `~/.local/bin`, checks the sha256 of the download, and installs the agent skill for each agent tool it finds.

Options go after `bash -s --`:

```sh
curl -fsSL https://raw.githubusercontent.com/Eventyret/peapod-dist/main/install.sh | bash -s -- --version v0.5.0
curl -fsSL https://raw.githubusercontent.com/Eventyret/peapod-dist/main/install.sh | bash -s -- --dir ~/bin
```

## Use

```sh
peapod
```

## Update

```sh
peapod update
peapod update --rollback
```

peapod tells you when a new version exists. `update` checks the sha256 before it replaces the binary and keeps the old one as `peapod.prev` next to it.

## Binaries

Each [release](https://github.com/Eventyret/peapod-dist/releases/latest) holds `peapod-<target>.gz` and a `.sha256` file for `macos-arm64`, `macos-x64`, `linux-x64` and `linux-arm64`.
