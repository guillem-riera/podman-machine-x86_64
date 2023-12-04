# Podman Machine Setup for x86_64 on Apple Silicon

This repository helps setting up a Podman machine (QEMU) on **Apple Silicon**, which will run **amd64 (x86_64) containers**.

There are 2 ways:

1. Enable multi-architecture support (including `x86_64`) on a normal `aarch64`. This way keeps performance high (but it still runs a base `aarch64` machine).
2. Fully emulated `x86_64` machines. Maximizes compatibility but it is slow.

Try always `1` before going to `2` (only use `2` if really needed).

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

## 1. Setup multi-arch support on current podman machine

This step will install the required package in the current machine.
the `setup.sh` script will take care of this process.

```bash
# export PODMAN_MACHINE_NAME="podman-machine-default"
# change this machine name if you want to setup another machine.
./setup.sh
```

Afterwards start the machine as usual.

Podman should now be able to run multiple architecture images with a performance penalty applied only to `x86_64` containers.

## 2. Setup `x86_64` full emulation

**Note**: this step is only required if the solution `1` is not enough for you.

The setup will create a Podman machine with the name `x86_64` and the default parameters.

### Create a Podman machine

```bash
./setup-x86_64.sh [optional podman machine parameters]
```

#### Example 1: Default size podman machine

```bash
./setup-x86_64.sh
```

#### Example 2: Custom size podman machine

```bash
./setup-x86_64.sh --cpus 8 --memory 16384 --disk-size 24
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
