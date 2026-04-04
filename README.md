**This README.md is 100% AI btw.**

# 📸 RPi Camera Streamer for HAOS

![Version](https://img.shields.io/badge/version-1.1.0-blue.svg) ![Home Assistant](https://img.shields.io/badge/Home%20Assistant-OS-41BDF5?logo=home-assistant) ![Architecture](https://img.shields.io/badge/architecture-aarch64-green.svg)

A high-performance, universal CSI/USB camera streamer built specifically to bridge the gap between **Home Assistant OS (HAOS)**, the **Raspberry Pi 5**, and AI NVRs like **Frigate**.

By bypassing standard Docker hardware limitations, this Add-on grants full `libcamera` access to the complex Raspberry Pi 5 pipeline, allowing you to stream raw hardware feeds (like the IMX500, IMX296 Global Shutter, or HQ cameras) directly to a built-in MediaMTX RTSP server.

---

## 🚀 Features

* **Universal Support:** Works out-of-the-box with all official Raspberry Pi Camera modules (V2, V3, HQ, IMX500, Global Shutter).
* **Dynamic Resolution:** No hardcoded limits. Input the exact max resolution of your specific sensor.
* **Frigate Optimized:** Automatically generates accurate wall-clock timestamps (`genpts`) to prevent Frigate `ffmpeg` crash loops and DTS timestamp spam.
* **Zero-Config Hardware Mapping:** Automatically binds to the Pi 5's memory heaps, sub-devices, and Media Controllers.

---

## ⚠️ Pi 5 Architecture & Performance Guide

The Raspberry Pi 5 introduced a massive architectural change: **It completely removed the dedicated H.264 hardware encoder.** All video encoding is now handled via software (`libav`) on the CPU. Because of this, pushing maximum resolutions will cause severe CPU bottlenecks. 

Based on extensive testing with HAOS and Hailo-8L AI chips, here are the required best practices for a stable system:

### 1. The 1080p Sweet Spot (Standard Cameras)
If you are using a standard camera (like the V3 or IMX500), **do not run at 4K (4056x3040)**. 
* Software-encoding a 4K stream will crush the Pi 5's CPU.
* AI tools like Frigate downscale images to `640x640` for processing anyway.
* **Recommendation:** Set your Add-on resolution to `1920x1080`. It provides perfectly crisp video for human review while keeping CPU usage incredibly low.

### 2. Framerate Limits
Security cameras and AI detection models do not need cinematic frame rates.
* **Recommendation:** Set your framerate to `10` or `15` FPS. Dropping from 30 FPS to 10 FPS cuts your CPU encoding load by **66%** instantly.

### 3. The Frigate Timestamp Fix
Native raw H.264 streams lack timing data. If you pipe a raw stream into Frigate, you will see massive log spam: `Non-monotonous DTS in output stream 0:0`. 
* **The Fix:** This Add-on natively rebuilds the timestamps using `-use_wallclock_as_timestamps 1` and `-fflags +genpts` before broadcasting to RTSP, completely solving Frigate compatibility.

---

## 📸 Global Shutter (GS) Support

Global Shutter cameras (like the Official RPi GS Camera) are the "holy grail" for AI object detection because they capture the entire frame in a single microsecond, completely eliminating motion blur on fast-moving objects (cars, running people).

### GS Configuration Requirements
The Sony IMX296 sensor used in the official GS camera has a very strict, non-standard pixel layout. **You cannot request 1080p from this camera.**

If you install a Global Shutter camera, you **must** update your Add-on configuration to its exact maximum resolution:

* **Resolution:** `1456x1088` (Required for IMX296)
* **Bitrate:** `5000000` (5 Mbps is plenty for this resolution)

*(Note: You may also need to update your HAOS `config.txt` from `camera_auto_detect=1` to `dtoverlay=imx296` depending on your specific board).*

---

## ⚙️ Add-on Configuration

In the Home Assistant Add-on UI, configure your camera settings. Because this add-on uses dynamic schemas, you can type your exact resolution directly into the text box.

```yaml
camera_path: "0"                # Default for single CSI camera
resolution: "1920x1080"         # Use "1456x1088" for Global Shutter
framerate: 15                   # Keep at 10-15 for low CPU usage
bitrate: 5000000                # 5-10 Mbps recommended
h264_profile: "high"            # H.264 encoding profile
