#!/usr/bin/with-contenv bashio

CAMERA_PATH=$(bashio::config 'camera_path')
RES=$(bashio::config 'resolution')
FPS=$(bashio::config 'framerate')
BITRATE=$(bashio::config 'bitrate')
PROFILE=$(bashio::config 'h264_profile')

bashio::log.info "Brawndo Corp Streamer Starting..."

# Start MediaMTX
/usr/local/bin/mediamtx /etc/mediamtx.yml &
sleep 2

WIDTH=$(echo $RES | cut -d'x' -f1)
HEIGHT=$(echo $RES | cut -d'x' -f2)

# Start rpicam-vid with IMX500 optimizations
rpicam-vid \
    -t 0 \
    --camera "${CAMERA_PATH}" \
    --width "$WIDTH" \
    --height "$HEIGHT" \
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
