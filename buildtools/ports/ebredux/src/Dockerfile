FROM rhh-base

USER root
ENV DEBIAN_FRONTEND=noninteractive

# Ubuntu focal ships Python 3.8 as /usr/bin/python3. The Deadsnakes PPA
# provides Python 3.9 for focal; use it without replacing system Python.
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates git software-properties-common python3-launchpadlib \
    cmake ninja-build build-essential pkg-config wget curl unzip zip \
    libasound2-dev libpulse-dev libudev-dev libx11-dev libxext-dev \
    libxrandr-dev libxcursor-dev libxinerama-dev libxi-dev libxss-dev \
    libwayland-dev libxkbcommon-dev libegl1-mesa-dev libgles2-mesa-dev \
    libdrm-dev libgbm-dev libibus-1.0-dev libdbus-1-dev \
    && add-apt-repository -y ppa:deadsnakes/ppa \
    && apt-get update \
    && apt-get install -y --no-install-recommends python3.9 \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /root
CMD ["bash"]
