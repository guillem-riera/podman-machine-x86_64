#!/usr/bin/env bash

### This script sets up multi-architecture support for an existing podman machine.
### It is intended to be run after the podman machine has been created with:
### podman machine init

PODMAN_MACHINE_NAME=${PODMAN_MACHINE_NAME:-podman-machine-default}

### Stop all podman machine instances
ALL_PODMAN_MACHINES=$(podman machine list | awk '{ print $1 }' | tr -d '*' | sed 1d | tr '\n' ' ')
for PODMAN_MACHINE in ${ALL_PODMAN_MACHINES}; do
    podman machine stop ${PODMAN_MACHINE}
done

### Start the target podman machine
podman machine start ${PODMAN_MACHINE_NAME}

### wait for the podman machine to be running
PODMAN_MACHINE_STATUS=$(podman machine inspect ${PODMAN_MACHINE_NAME} | jq -r '.[].State')
while [[ "${PODMAN_MACHINE_STATUS}" != "running" ]]; do
    echo "[Info] Waiting for podman machine '${PODMAN_MACHINE_NAME}' to be running, current status: ${PODMAN_MACHINE_STATUS}..."
    sleep 1
    PODMAN_MACHINE_STATUS=$(podman machine inspect ${PODMAN_MACHINE_NAME} | jq -r '.[].State')
done

### Now that the podman machine is running we can install the package
podman machine ssh "${PODMAN_MACHINE_NAME}" 'sudo rpm-ostree install qemu-user-static'

### Stop the podman machine to apply the changes
podman machine stop ${PODMAN_MACHINE_NAME}

### Start the podman machine again
podman machine start ${PODMAN_MACHINE_NAME}

echo "[Info] Done. You can now run multi-architecture images in ${PODMAN_MACHINE_NAME}."
