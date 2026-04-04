ARG BUILD_FROM=ghcr.io/home-assistant/aarch64-base-debian:bookworm
FROM ${BUILD_FROM}

# Install RPi Camera Stack, MediaMTX dependencies, and FFmpeg
RUN apt-get update && apt-get install -y --no-install-recommends \
    wget \
    ca-certificates \
    gnupg \
    && \
    mkdir -p /usr/share/keyrings \
    && curl -fsSL https://archive.raspberrypi.com/debian/raspberrypi.gpg.key \
        | gpg --dearmor -o /usr/share/keyrings/raspberrypi-archive-keyring.gpg \
    && echo "deb [signed-by=/usr/share/keyrings/raspberrypi-archive-keyring.gpg] http://archive.raspberrypi.com/debian/ bookworm main" \
        > /etc/apt/sources.list.d/raspi.list \
    && apt-get update && apt-get install -y --no-install-recommends \
        libcamera-apps \
        libcamera-v4l2 \
        # libcamera0 \
        # libcamera-ipa \
        v4l-utils \
        ffmpeg \
    && rm -rf /var/lib/apt/lists/*
# Install MediaMTX (RTSP Server)
ARG MEDIAMTX_VERSION=v1.17.1
RUN wget https://github.com/bluenviron/mediamtx/releases/download/${MEDIAMTX_VERSION}/mediamtx_${MEDIAMTX_VERSION}_linux_arm64.tar.gz \
    && tar -xzf mediamtx_${MEDIAMTX_VERSION}_linux_arm64.tar.gz -C /usr/local/bin mediamtx \
    && rm mediamtx_${MEDIAMTX_VERSION}_linux_arm64.tar.gz

# Prepare MediaMTX config
RUN printf "paths:\n  all:\n    source: publisher\n    rtspTransport: tcp\n" > /etc/mediamtx.yml
# Copy the startup script
COPY run.sh /
RUN chmod a+x /run.sh

# Entry point
CMD [ "/run.sh" ]
