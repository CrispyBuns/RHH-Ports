FROM rhh-base

USER root
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates git python3 cmake ninja-build build-essential pkg-config \
    wget curl unzip zip \
    libasound2-dev libpulse-dev libudev-dev libx11-dev libxext-dev \
    libxrandr-dev libxcursor-dev libxinerama-dev libxi-dev libxss-dev \
    libwayland-dev libxkbcommon-dev libegl1-mesa-dev libgles2-mesa-dev \
    libdrm-dev libgbm-dev libibus-1.0-dev libdbus-1-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /root
CMD ["bash"]
