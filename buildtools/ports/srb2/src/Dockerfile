FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

# Ubuntu 24.04 provides GCC 13 (C23 support) and glibc 2.39. The latter is
# below the RG35XX-H KNULLI runtime's glibc 2.40, preserving compatibility.
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates git cmake ninja-build build-essential pkg-config binutils file \
    libsdl2-dev libsdl2-mixer-dev \
    libpng-dev zlib1g-dev libcurl4-openssl-dev \
    libopenmpt-dev libgme-dev libminiupnpc-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /root
CMD ["bash"]
