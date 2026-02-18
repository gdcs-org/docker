# docker

## BPI SDK Docker Compose

This repository contains a Docker Compose configuration for running the BPI SDK in a containerized environment.

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
