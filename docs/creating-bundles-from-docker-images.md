# Creating Dobby Bundles from Docker Images

This guide covers the workflow for creating Dobby-compatible OCI bundles for the BananaPi 4 RDK Broadband platform:

---

## Workflow: Build and bundle with docker build

### 1. Create metadata.json

Bundlegen requires an `metadata.json` that describes the app to Dobby. Third-party
images (like Ubuntu and Alpine) do not embed one, so you must create and pass it explicitly with
`-a`.

Create `/tmp/metadata.json`:

```bash
cat > /tmp/metadata.json << 'EOF'
{
    "id": "com.rdk.myapp",
    "type": "application/vnd.rdk-app.dac.native",
    "version": "1.0.0",
    "description": "My application",
    "priority": "optional",
    "graphics": false,
    "network": {
        "type": "open"
    },
    "storage": {},
    "resources": {
        "ram": "512M"
    },
    "features": [],
    "mounts": []
}
EOF
```

### 2. Write a Dockerfile

```Dockerfile
FROM --platform=linux/arm64 debian:bookworm-slim
RUN apt-get update && apt-get install -y --no-install-recommends \
    myapp && rm -rf /var/lib/apt/lists/*
ENTRYPOINT ["/usr/bin/myapp"]
```

### 3. Build the image

```bash
docker build -f Dockerfile --network=host -t myapp:latest .
```

### 4. Convert to OCI layout

```bash
skopeo copy docker-daemon:myapp:latest oci:/tmp/myapp-oci:latest
```

### 5. Generate the Dobby bundle

```bash
bundlegen -vvv generate \
   --platform bpir4_reference \
   -a /tmp/metadata.json \
   oci:/tmp/myapp-oci:latest \
   /tmp/myapp_bundle
```
**Note:** For non-glibc images such as Alpine, `--crun` must be added to the bundlegen arguments.

This produces `/tmp/myapp_bundle.tar.gz`.

### 6. Start the container

```bash
DobbyTool start myapp /tmp/myapp_bundle
```

### 7. Manage the container

**DobbyTool**:

```bash
# Check status
DobbyTool list

# Login to the container
# Note: Using crun because DobbyTool exec will execute the command and exit
crun exec -t myapp sh

# Stop the container
DobbyTool stop myapp

# Force-stop (SIGKILL)
DobbyTool stop myapp --force
```

___

## Platform Templates

Available platform templates can be found under /usr/share/bundlegen/templates/
