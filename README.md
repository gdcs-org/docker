# docker

## Table of Contents

- [docker](#docker)
  - [Table of Contents](#table-of-contents)
  - [BPI SDK Docker Compose](#bpi-sdk-docker-compose)
    - [About the Image](#about-the-image)
    - [Usage](#usage)
    - [What's Included](#whats-included)
  - [BPI Dev Docker Compose](#bpi-dev-docker-compose)
    - [About the Image](#about-the-image-1)
    - [Usage](#usage-1)
    - [What's Included](#whats-included-1)
    - [Manual Docker Run (Alternative)](#manual-docker-run-alternative)
  - [BPI vCPE Docker Compose](#bpi-vcpe-docker-compose)
    - [About the Image](#about-the-image-2)
    - [Usage](#usage-2)
    - [What's Included](#whats-included-2)
  - [Running ARM64 containers on x86\_64](#running-arm64-containers-on-x86_64)
      - [Linux](#linux)
      - [Windows](#windows)

## BPI SDK Docker Compose

This repository contains a Docker Compose configuration for running the BPI SDK in a containerized environment.

### About the Image

The `ghcr.io/gdcs-org/sdk/bpi:latest` is a multi-platform image that runs natively on ARM64 and x86_64 machines. The SDK is located under /opt/sdk and environment variables are automatically set when accessing the container. The SDK environment variables can be found in /opt/sdk/environment-setup-cortexa53-rdk-linux. The image includes an opkg wrapper to direct installations to the target sysroot. To see available packages, run `opkg update` and `opkg list`. To install packages in the host container, use `apt`.

### Usage

**Start the container:**
```bash
docker compose -f compose-bpi-sdk.yaml up -d
```

**Access the container shell:**
```bash
docker exec -it bpi-sdk bash
```

**Stop the container:**
```bash
docker compose -f compose-bpi-sdk.yaml down
```

### What's Included

The volume mounts in the compose file should be modified for the user's environment. The example sets up a privileged container with:
- **Workspace**: `~/projects/packages/workflows` mounted to `/workspace`
- **Git credentials**: `.netrc`, `.git-credentials`, and `.gitconfig` mounted as read-only
- **SSH keys**: `~/.ssh` directory mounted as read-only
- **Network**: Host networking mode for direct network access

## BPI Dev Docker Compose

This repository also contains a Docker Compose configuration for running the BPI development environment in a containerized environment.

### About the Image

The `ghcr.io/gdcs-org/dev/bpi:latest` image is an arm64 image that emulates RDK running on a BananaPi. The container should be started using the compose file to automatically start the RDK services. The image contains all the build tools of the SDK as well as opkg and pip3 for installing packages.

### Usage

**Start the container:**
```bash
docker compose -f compose-bpi-dev.yaml up -d
```

**Access the container shell:**
```bash
docker exec -it bpi-dev bash
```

**Stop the container:**
```bash
docker compose -f compose-bpi-dev.yaml down
```

### What's Included

The volume mounts in the compose file should be modified for the user's environment. The example sets up a privileged container with:
- **Platform**: linux/arm64
- **Workspace**: `~/projects/packages/workflows` mounted to `/workspace`
- **Git credentials**: `.netrc`, `.git-credentials`, and `.gitconfig` mounted as read-only
- **SSH keys**: `~/.ssh` directory mounted as read-only

### Manual Docker Run (Alternative)

The container can also be started manually with `docker run`. The following example uses the options from compose file. Note that manual run starting bash will not automatically start the RDK services and this is a better option when running on a x86_64 machine:

```bash
docker run -it \
  --platform linux/arm64 \
  --privileged \
  --hostname bpi-dev \
  --name bpi-dev \
  -v ~/projects/packages/workflows:/workspace:Z \
  -v ~/.netrc:/home/root/.netrc:ro \
  -v ~/.git-credentials:/home/root/.git-credentials:ro \
  -v ~/.gitconfig:/home/root/.gitconfig:ro \
  -v ~/.ssh:/home/root/.ssh:ro \
  ghcr.io/gdcs-org/dev/bpi:latest \
  bash
```

## BPI vCPE Docker Compose

This repository also contains a Docker Compose configuration for running a lightweight BPI vCPE environment in a containerized environment.

### About the Image

The `ghcr.io/gdcs-org/vcpe/bpi:latest` image is an arm64 image that provides a lightweight RDK environment with only the base RDK services included. Additional services, development packages, and tools can be installed at runtime using `opkg`.

### Usage

**Start the container:**
```bash
docker compose -f compose-bpi-vcpe.yaml up -d
```

**Access the container shell:**
```bash
docker exec -it bpi-vcpe bash
```

**Stop the container:**
```bash
docker compose -f compose-bpi-vcpe.yaml down
```

**Install additional packages with opkg:**
```bash
opkg update
opkg list
opkg install <package-name>
```

### What's Included

The volume mounts in the compose file should be modified for the user's environment. The example sets up a privileged container with:
- **Platform**: linux/arm64
- **Workspace**: `~/projects/packages/workflows` mounted to `/workspace`
- **Git credentials**: `.netrc`, `.git-credentials`, and `.gitconfig` mounted as read-only
- **SSH keys**: `~/.ssh` directory mounted as read-only

**Notes:** 
   * Add `--rm` to the `docker run` command to automatically remove the container when exiting.
   * This image uses an RDK built kernel and the root home is /home/root instead of /root like the SDK image, so make sure the mounts are correct for ssh keys and git configurations to work as expected.

## Running ARM64 containers on x86_64

To run ARM64 containers on x86_64 architecture, you need to install and configure multi-platform support using QEMU.

#### Linux

**Install QEMU and register binary formats:**

```bash
# Install QEMU user-static
sudo apt-get update
sudo apt-get install -y qemu-user-static

# Register binary formats for multi-platform support
docker run --rm --privileged multiarch/qemu-user-static --reset -p yes
```

**Verify multi-platform support:**

```bash
# Check available platforms
docker buildx ls

# Verify ARM64 support
docker run --rm --platform linux/arm64 arm64v8/alpine uname -m
```

Expected output: `aarch64`

#### Windows

**Install QEMU (using WSL2):**

Since Docker Desktop for Windows uses WSL2, you'll need to set up QEMU within WSL2:

```bash
# From WSL2 terminal
sudo apt-get update
sudo apt-get install -y qemu-user-static

# Register binary formats
docker run --rm --privileged multiarch/qemu-user-static --reset -p yes
```

**Verify multi-platform support:**

```bash
# Check available platforms
docker buildx ls

# Verify ARM64 support
docker run --rm --platform linux/arm64 arm64v8/alpine uname -m
```

Expected output: `aarch64`

**Note:** Docker Desktop for Windows should have buildx enabled by default. If not, enable it in Docker Desktop settings under "Features in development" > "Use Docker Buildx".
