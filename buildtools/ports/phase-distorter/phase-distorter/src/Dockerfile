FROM rhh-base
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    ninja-build libgl-dev libegl1-mesa-dev libgles2-mesa-dev \
    && rm -rf /var/lib/apt/lists/*
