FROM rhh-base

ENV DEBIAN_FRONTEND=noninteractive

RUN apt update && apt install -y --no-install-recommends \
    libsdl2-dev python3 \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /root

CMD ["bash"]
