#!/usr/bin/with-contenv bashio

# --- CONFIGURATION RETRIEVAL ---
# Using bashio to pull settings from the Home Assistant UI
CAMERA_PATH=$(bashio::config 'camera_path')
RES=$(bashio::config 'resolution')
FPS=$(bashio::config 'framerate')
BITRATE=$(bashio::config 'bitrate')
PROFILE=$(bashio::config 'h264_profile')

bashio::log.info "Starting RPi Camera Streamer..."
bashio::log.info "Targeting Camera: ${CAMERA_PATH} at ${RES} (${FPS} FPS)"
bashio::log.info "Stream Bitrate: $((BITRATE / 1000)) kbps"

# --- SERVICE INITIALIZATION ---
# Start MediaMTX in the background to act as our RTSP Gateway
# This allows multiple apps (Frigate + HA Dashboard) to view the stream
/usr/local/bin/mediamtx /etc/mediamtx.yml &
sleep 3

# --- STREAMING ENGINE (Optimized for RPi 5 & IMX500) ---
# --inline: Force headers in every frame (Required for Frigate)
# --flush: Push frames immediately to reduce latency
# --denoise cdn_off: Disables color denoise to save processing time on AI sensors
# --level 4.2: Required for high-bitrate H.264
# We pipe the raw stream into ffmpeg to wrap it into an RTSP container

rpicam-vid \
    -t 0 \
    --camera "${CAMERA_PATH}" \
    --width "$(echo $RES | cut -d'x' -f1)" \
    --height "$(echo $RES | cut -d'x' -f2)" \
    --framerate "${FPS}" \
    --bitrate "${BITRATE}" \
    --profile "${PROFILE}" \
    --level 4.2 \
    --inline \
    --flush \
    --denoise cdn_off \
    --nopreview \
    -o - | ffmpeg \
        -hide_banner \
        -loglevel error \
        -i - \
        -c copy \
        -f rtsp \
        -rtsp_transport tcp \
        rtsp://localhost:8554/live
