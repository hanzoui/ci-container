FROM mcr.microsoft.com/playwright/python:v1.57.0-noble

# Install Node.js and pnpm
RUN apt-get update && \
    apt-get install -y curl && \
    curl -fsSL https://deb.nodesource.com/setup_24.x | bash - && \
    apt-get install -y nodejs && \
    npm install -g pnpm && \
    rm -rf /var/lib/apt/lists/*

# ComfyUI version to cache (update when new version released)
ARG COMFYUI_VERSION=v0.5.1

# Clone ComfyUI at pinned version
RUN git clone --depth 1 --branch ${COMFYUI_VERSION} \
    https://github.com/comfyanonymous/ComfyUI.git /ComfyUI

# Pre-create custom_nodes directory for devtools
RUN mkdir -p /ComfyUI/custom_nodes/ComfyUI_devtools

# Install Python dependencies (all cached in image)
RUN pip3 install --upgrade pip --break-system-packages && \
    pip3 install torch torchvision torchaudio \
      --index-url https://download.pytorch.org/whl/cpu --break-system-packages && \
    pip3 install -r /ComfyUI/requirements.txt --break-system-packages && \
    pip3 install wait-for-it --break-system-packages

WORKDIR /app
