# Firebolt Example Container

Instructions for building and running the USP Greeter Python example container.

## Steps

### 1. Create the application metadata

```bash
cat > /tmp/metadata.json << 'EOF'
{
    "id": "com.rdk.myapp",
    "type": "application/vnd.rdk-app.dac.native",
    "version": "1.0.0",
    "description": "My USP application",
    "priority": "optional",
    "graphics": false,
    "network": {
        "type": "open"
    },
    "storage": {},
    "resources": {
        "ram": "128M"
    },
    "features": [],
    "mounts": []
}
EOF
```

### 2. Build the Docker image

```bash
docker build -f Dockerfile -t usp-greeter-python .
```

### 3. Copy the image to an OCI layout

```bash
skopeo copy docker-daemon:usp-greeter-python:latest oci:/tmp/usp-greeter-python:latest
```

### 4. Generate the bundle

```bash
bundlegen -v generate \
   --platform bpir4_reference_usp \
   -a /tmp/metadata.json \
   oci:/tmp/usp-greeter-python:latest \
   /tmp/usp-greeter-python_bundle
```

### 5. Start the container with Dobby

```bash
DobbyTool start usp-greeter-python /tmp/usp-greeter-python_bundle
```

### 6. Verify the container is running

```bash
DobbyTool list
```

### 7. Invoke the greeter via USP

```bash
UspPa -c get Device.Greeter.
```
