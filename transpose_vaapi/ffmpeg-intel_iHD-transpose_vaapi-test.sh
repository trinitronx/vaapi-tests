#!/bin/sh
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Tried forcing /usr/lib/dri/iHD_drv_video.so
# Same results
# export LIBVA_DRIVERS_PATH=/usr/lib/dri/
# export LIBVA_DRIVER_NAME=iHD
# export LIBVA_DRIVER_NAME=i965
# export LIBVA_DRIVER_NAME=radeonsi

# hw_dev_name='intel0'
# hw_device='vaapi=intel0:/dev/dri/renderD128,gpu_mem_limit=67108864'

hw_dev_name='amd0'
hw_device='vaapi=amd0:/dev/dri/renderD129'

vf_dev_name='intel0'
vf_device='vaapi=intel0:/dev/dri/renderD128,kernel_driver=iHD'
# vf_dev_name='amd0'

#num_cpus=$(nproc --all | head -n1)
num_cpus=1  # Trying just 1 CPU... still gives memory error!

# Even very small video gives memory error... WTF?
input_testfile=${SCRIPT_DIR}/whitenoise-test-input-720x405.amd0.h264.mp4 # Test whitenoise video input 720x405


# Tried hevc encoding and/or scale_vaapi with very small dimensions
# It gave the same error: "Error while filtering: Cannot allocate memory"
# Command was originally to correct a 90° flipped iPhone video (`.mov`, HEVC 10-bit)
#    -vf 'format=nv12|vaapi,hwupload,scale_vaapi=w=320:h=180' \
#    -map 0:0 -c:v hevc_vaapi -global_quality 25 -profile:v:0 main10 \
# -hwaccel_flags 'allow_profile_mismatch+allow_high_depth' \
# -hwaccel_device "${hw_dev_name}"
ffmpeg -report -benchmark_all -nostdin -v debug \
  -threads ${num_cpus} \
  -hwaccel vaapi -hwaccel_output_format vaapi \
  -dec 0:0 -init_hw_device "${hw_device}"  -vaapi_device "${hw_dev_name}" \
  -i "$input_testfile" \
    -map 0:0 -c:v hevc_vaapi -global_quality 25 -refs 1 -max_b_frames 0 -bf 0 -g 30 -profile:v:0 main \
    -map 0:a -c:a copy \
    -init_hw_device "${vf_device}" -filter_hw_device "${vf_dev_name}" \
    -vf 'format=nv12|vaapi,hwupload=extra_hw_frames=3,transpose_vaapi=cclock' \
  -f mp4 -y  "${SCRIPT_DIR}"/out.mp4



#  ffmpeg -vaapi_device /dev/dri/renderD128 -i "$input_testfile" \
#  -vf 'format=nv12|vaapi,hwupload,transpose_vaapi=clock' \
#  -c:v h264_vaapi -qp 23 -c:a copy -y "${SCRIPT_DIR}/out.mp4"
