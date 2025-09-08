#!/bin/sh

scale_size=1366:768
mpv -no-config -hwdec=auto -vf=denoise_vaapi,scale_vaapi=$scale_size:nv12:hq $1
