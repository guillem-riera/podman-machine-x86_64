# Podman Machine Setup for x86_64 on Apple Silicon

This repository helps setting up a Podman machine (QEMU) on **Apple Silicon**, which will run **amd64 (x86_64) containers**.

## Requirements

- homebrew
- homebrew bundle
- podman
- qemu (dependency of podman, included automatically)
- jq

Note: `qemu` is included in the list because it is necessary to pin the version too.

The required packages can be found in the `Brewfile`.

install the dependencies if not otherwise done:

```bash
brew bundle install
```

## Setup

The default setup will create a Podman machine with the name `x86_64` and the default parameters.

### Create a Podman machine

```bash
./setup.sh [optional podman machine parameters]
```

#### Example 1: Default size podman machine

```bash
./setup.sh
```

#### Example 2: Custom size podman machine

```bash
./setup.sh --cpus 8 --memory 16384 --disk-size 24
```

### Start the Podman machine

**Note:** The Podman machine needs to be started after every reboot and it might take a very long time to start, specially the first time (as it configures itself with ignition).

```bash
podman machine start x86_64
```

### Change the settings afterwards

You will have to modify the `x86_64.json` file and then restart the Podman machine.

```bash
podman machine stop x86_64
code $HOME/.config/containers/machines/x86_64.json
podman machine start x86_64
```
