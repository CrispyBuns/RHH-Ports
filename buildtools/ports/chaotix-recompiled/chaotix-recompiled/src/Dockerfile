FROM rhh-base

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates git pkg-config \
    libasound2-dev libpulse-dev libwayland-dev libx11-dev libxext-dev \
    libxrandr-dev libxcursor-dev libxfixes-dev libxi-dev libxinerama-dev \
    libxkbcommon-dev libxss-dev libxt-dev libgl1-mesa-dev libegl1-mesa-dev \
    libdrm-dev libgbm-dev libudev-dev libibus-1.0-dev libdbus-1-dev \
    libfreetype-dev libharfbuzz-dev libpng-dev libjpeg-dev libwebp-dev \
    libtiff-dev libbrotli-dev \
    && rm -rf /var/lib/apt/lists/*
