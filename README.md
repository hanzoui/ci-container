# Hanzo Studio Test Action

A Docker container image pre-configured for running Playwright E2E tests against Hanzo Studio.

## What's Included

- Playwright browsers (Chromium, Firefox, WebKit)
- Node.js + pnpm
- Python 3 + pip
- Hanzo Studio backend (pinned version) at `/Hanzo Studio`
- All Python dependencies pre-installed (torch CPU, requirements.txt, wait-for-it)

## Usage

Use this image as a container in your GitHub Actions workflow:

```yaml
jobs:
  test:
    runs-on: ubuntu-latest
    container:
      image: ghcr.io/comfy-org/hanzo-studio-ci-container:v1
    strategy:
      matrix:
        shard: [1, 2, 3, 4]
    steps:
      - uses: actions/checkout@v5

      - uses: actions/download-artifact@v4
        with:
          name: frontend-dist
          path: dist

      # Setup - just copy devtools and start server (no clone, no pip install)
      - name: Setup Hanzo Studio
        run: |
          ln -sf /Hanzo Studio ./Hanzo Studio
          cp -r ./tools/devtools/* /Hanzo Studio/custom_nodes/Hanzo Studio_devtools/
          cd /Hanzo Studio && python3 main.py --cpu --multi-user --front-end-root $GITHUB_WORKSPACE/dist &
          wait-for-it --service 127.0.0.1:8188 -t 600

      - name: Install frontend deps
        run: pnpm install

      - name: Run tests
        run: pnpm exec playwright test --shard=${{ matrix.shard }}/4
```

## Image Tags

- `ghcr.io/comfy-org/hanzo-studio-ci-container:latest` - Latest build
- `ghcr.io/comfy-org/hanzo-studio-ci-container:0.0.3` - Stable v0.0.3
- `ghcr.io/comfy-org/hanzo-studio-ci-container:hanzo-studio-v0.5.1` - Specific Hanzo Studio version

## Time Savings

| Step | Before | After |
|------|--------|-------|
| Clone Hanzo Studio | ~10s | 0s |
| pip install | ~90s | 0s |
| Setup Playwright | ~30s | 0s |
| **Total saved** | **~130s** | **per shard** |

## Local Development

```bash
# Build the image
docker build -t hanzo-studio-test:local .

# Run interactively
docker run -it --rm -v $(pwd):/app hanzo-studio-test:local bash

# Test Hanzo Studio is installed
docker run --rm hanzo-studio-test:local python3 -c "import torch; print(torch.__version__)"
```

## Updating Hanzo Studio Version

1. Update `COMFYUI_VERSION` in Dockerfile
2. Push to trigger rebuild
3. Tag with new version
