#!/bin/sh
mpv --vo=gpu-next --hwdec=vaapi --vaapi-device=/dev/dri/renderD129  ./demo.av1.mkv
