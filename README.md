# peapod

peapod links a local Shapeshift library checkout into the API and frontend repos that use it. It replaces `npm run link` and picks v4 or v5 from the repo's library version.

## Install

```sh
curl -fsSL https://raw.githubusercontent.com/Eventyret/peapod-dist/main/install.sh | bash
```

It installs to `~/.local/bin`. Set `PEAPOD_BIN_DIR` to install somewhere else.

## Use

```sh
peapod setup
```

Then, inside a consumer repo:

```sh
peapod          # link the library into this repo
peapod check    # confirm every link points at the library
peapod --update # install the latest release
```

## Go back

Run `npm run link` in the consumer repo as before.

## Binaries

Each [release](https://github.com/Eventyret/peapod-dist/releases/latest) attaches `peapod-<target>.gz` for `macos-arm64`, `macos-x64`, `linux-x64` and `linux-arm64`.
