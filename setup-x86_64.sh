# Setup the podman machine for x86_64 (QEMU), supports only Apple Silicon (Mx) Macs

# Keep all shell arguments in a variable to pass to the podman machine init command:
EXTRA_ARGS=${EXTRA_ARGS:-$@}

## 1. Download Fedora CoreOS image for x86_64 (QEMU)
PODMAN_X86_64_MACHINE_NAME=${PODMAN_X86_64_MACHINE_NAME:-x86_64}
PODMAN_X86_64_MACHINE_NAME_EXISTS=$(podman machine list | grep ${PODMAN_X86_64_MACHINE_NAME} | wc -l | tr -d '[:space:]')
PODMAN_QEMU_IMAGE="fedora-coreos-39.20231101.3.0-qemu.x86_64.qcow2.xz"
DOWNLOAD_DIR=${DOWNLOAD_DIR:-.}

if [ ${PODMAN_X86_64_MACHINE_NAME_EXISTS} -lt 1 ]; then
    curl -C- -O "https://builds.coreos.fedoraproject.org/prod/streams/stable/builds/39.20231101.3.0/x86_64/${PODMAN_QEMU_IMAGE}"
    podman machine init --image-path ${DOWNLOAD_DIR}/${PODMAN_QEMU_IMAGE} ${PODMAN_X86_64_MACHINE_NAME} ${EXTRA_ARGS}
else
    echo "[Info] Machine ${PODMAN_X86_64_MACHINE_NAME} already exists. If you want to recreate it, run 'podman machine rm ${PODMAN_X86_64_MACHINE_NAME}'"
fi

## 2. Change machine settings

### Get the machine config file name
machineConfigFile="$(podman machine inspect ${PODMAN_X86_64_MACHINE_NAME} | jq -r '.[].ConfigPath.Path')"

### Change the QEMU binary to x86_64
sed -i '' 's/qemu-system-aarch64/qemu-system-x86_64/g' ${machineConfigFile}
### Change the firmware to x86_64
sed -i '' 's/edk2-aarch64-code/edk2-x86_64-code/g' ${machineConfigFile}
### Delete the additional UEFI firmware file (ovmf) and the preceding '-drive' option. The '-drive' option is in a line above the line containing the path to 'x86_64_ovmf_vars.fd'. Both lines must be deleted, but other -drive options must be kept.
#### using sed to match 2 lines: '-drive' followed by 'x86_64_ovmf_vars.fd'
sed -i '' '/-drive/{N;/x86_64_ovmf_vars.fd/d;}' ${machineConfigFile}
### Delete the HVF (Hypervisor Framework) acceleration, which is only available for macOS. This are also 2 lines: '-accel' followed by 'hvf'
sed -i '' '/-accel/{N;/hvf/d;}' ${machineConfigFile}
### Delete the TCG acceleration, which seems to work only for Alpha and ARM architectures. This are also 2 lines: '-accel' followed by 'tcg'
sed -i '' '/-accel/{N;/tcg/d;}' ${machineConfigFile}
### Change the machine type to q35
sed -i '' 's/virt,highmem=on/q35/g' ${machineConfigFile}
### Change the cpu type from 'host' to 'qemu64'
sed -i '' 's/host/qemu64/g' ${machineConfigFile}
