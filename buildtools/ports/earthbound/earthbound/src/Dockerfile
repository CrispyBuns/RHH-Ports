FROM rhh-base

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    git python3 python3-venv python3-pip pkg-config ca-certificates \
    && rm -rf /var/lib/apt/lists/*
