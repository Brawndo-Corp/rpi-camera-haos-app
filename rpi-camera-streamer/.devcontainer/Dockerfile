ARG BUILD_FROM=ghcr.io/home-assistant/aarch64-base-debian:bookworm
FROM ${BUILD_FROM}

# Install RPi Camera Stack, MediaMTX dependencies, and FFmpeg
RUN apt-get update && apt-get install -y --no-install-recommends \
    libcamera-apps-lite \
    libcamera-v4l2 \
    v4l-utils \
    ffmpeg \
    wget \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Install MediaMTX (RTSP Server)
ARG MEDIAMTX_VERSION=v1.17.1
RUN wget https://github.com/bluenviron/mediamtx/releases/download/${MEDIAMTX_VERSION}/mediamtx_${MEDIAMTX_VERSION}_linux_arm64v8.tar.gz \
    && tar -xzf mediamtx_${MEDIAMTX_VERSION}_linux_arm64v8.tar.gz -C /usr/local/bin mediamtx \
    && rm mediamtx_${MEDIAMTX_VERSION}_linux_arm64v8.tar.gz

# Prepare MediaMTX config
RUN echo "paths:\n  all:\n    source: publisher\n    rtspTransport: tcp" > /etc/mediamtx.yml
# Copy the startup script
COPY run.sh /
RUN chmod a+x /run.sh

# Entry point
CMD [ "/run.sh" ]
