#!/usr/bin/with-contenv bashio

CAMERA_PATH=$(bashio::config 'camera_path')
RES=$(bashio::config 'resolution')
FPS=$(bashio::config 'framerate')
BITRATE=$(bashio::config 'bitrate')
PROFILE=$(bashio::config 'h264_profile')

bashio::log.info "RPi Camera Streamer Starting..."

#echo "========================================"
#echo "TESTING LIBCAMERA HARDWARE ACCESS..."
#echo "========================================"

# Ask libcamera to list all physically connected sensors
#rpicam-hello --list-cameras

#echo "========================================"
#echo "TEST FINISHED. KEEPING CONTAINER ALIVE..."
#echo "========================================"

# Sleep for a few minutes so the Home Assistant Supervisor doesn't 
# immediately see the script end and trigger a crash loop
#sleep 300
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
    --libav-format h264 \
    -o - | ffmpeg \
        -hide_banner \
        -loglevel error \
        -f h264 \
        -i - \
        -c copy \
        -f rtsp \
        -rtsp_transport tcp \
        rtsp://localhost:8554/live
