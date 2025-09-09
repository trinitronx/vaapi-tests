#!/bin/sh
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

#export LIBVA_DRIVERS_PATH=/usr/lib/dri/
#export LIBVA_DRIVER_NAME=iHD
hw_dev_name='intel0'
hw_device='vaapi=intel0:/dev/dri/renderD128'
#hw_device='vaapi=intel0:,kernel_driver=i915'
#hw_dev_name='amd0'
#hw_device='vaapi=amd0:/dev/dri/renderD129'

#vf_dev_name='intel0'
#vf_device='vaapi=intel0:/dev/dri/renderD128'
vf_dev_name='amd0'
vf_device='vaapi=amd0:/dev/dri/renderD129'

num_cpus=$(nproc --all | head -n1)

# Single remuxed file from: yt-dlp -f 'ba,bv' -o '%(title)s.f%(format_id)s.%(ext)s'
input_video_file="${SCRIPT_DIR}/demo.mp4"

# Command to decode vp9 video on Intel iGPU, and re-encode av1 video on AMD dGPU
# 

#DEBUG='-v debug'
DEBUG='-v verbose'

# Fix A/V sync by delaying video
#input_video_flags="-itsoffset 250ms"
#output_codec_flags="-global_quality 25 -rc_mode CQP -qp 18 -preset 7 -profile:v:0 main"
#output_codec_flags="-global_quality:v 32 -compression_level:v 2 -g 128 -rc_mode 1"
output_codec_flags="-rc_mode QVBR -b:v 3M -q:v 51 -level 4.0 -g 128 -compression_level:v 2"

ffmpeg -report -nostdin ${DEBUG} \
  -threads ${num_cpus} -init_hw_device ${hw_device} \
  -init_hw_device ${vf_device} \
  -extra_hw_frames 10 \
    -hwaccel vaapi -hwaccel_output_format nv12 -hwaccel_device ${hw_dev_name} \
    \
    $input_video_flags \
    \
    -i "$input_video_file" \
  -filter_hw_device amd0 \
  -vf 'format=nv12|vaapi,hwupload=extra_hw_frames=40' \
    -c:v av1_vaapi $output_codec_flags \
    -c:a copy \
    -map_metadata 0:g \
   -movflags +use_metadata_tags -y  "${input_video_file%.mp4}.av1.mkv"

