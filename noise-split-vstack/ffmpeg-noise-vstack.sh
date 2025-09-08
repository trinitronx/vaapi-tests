#!/bin/sh
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Tried forcing /usr/lib/dri/iHD_drv_video.so
# Same results
#export LIBVA_DRIVERS_PATH=/usr/lib/dri/
#export LIBVA_DRIVER_NAME=iHD

hw_dev_name='amd0'
hw_device='vaapi=amd0:/dev/dri/renderD129'

vf_dev_name='amd0'

#hw_dev_name='intel0'
#hw_device='vaapi=intel0:/dev/dri/renderD128'
#vf_dev_name='intel0'

#num_cpus=$(nproc --all | head -n1)
num_cpus=1  # Trying just 1 CPU... still gives memory error!

# Even very small video gives memory error... WTF?
#input_testfile=${SCRIPT_DIR}/whitenoise-test-input-720x405.amd0.h264.mp4 # Test whitenoise video input 720x405
input_testfile='/home/trinitronx/Downloads/Senator Cory Booker20250401Cory Booker starts his long Senate floor speech on Trump, Musk and more ｜ Part One~0.mkv'


# Tried hevc encoding and/or scale_vaapi with very small dimensions
# It gave the same error: "Error while filtering: Cannot allocate memory"
# Command was originally to correct a 90° flipped iPhone video (`.mov`, HEVC 10-bit)
#    -vf 'format=nv12|vaapi,hwupload,scale_vaapi=w=320:h=180' \
#    -map 0:0 -c:v hevc_vaapi -global_quality 25 -profile:v:0 main10 \

#    -vf 'format=nv12|vaapi,hwupload,transpose_vaapi=clock' \

# Intel only: denoise_vaapi test
#    -filter_complex "[0:v]format=nv12|vaapi,hwupload,scale_vaapi=w=1280:h=720,hwdownload[a];[a]noise=c0s=20:allf=t,split[noise][b];[noise]format=nv12|vaapi,hwupload,denoise_vaapi=denoise=64[vout1];[b]format=nv12|vaapi,hwupload[vout2];[vout1][vout2]vstack_vaapi=inputs=2:extra_hw_frames=10[out_v]" \
ffmpeg -report -nostdin -v debug \
  -ss 00:00:00 -to 00:00:37  \
  -threads ${num_cpus} -init_hw_device ${hw_device} \
  -hwaccel vaapi -hwaccel_output_format vaapi -hwaccel_device ${hw_dev_name} \
  -i "$input_testfile" \
    -filter_hw_device ${vf_dev_name} \
    -filter_complex_threads 16 \
    -filter_complex "[0:v]format=nv12|vaapi,hwupload,scale_vaapi=w=1280:h=720,hwdownload,split[a][b];[a]noise=c0s=30:allf=t[noise];[noise]format=nv12|vaapi,hwupload[vout1];[b]format=nv12|vaapi,hwupload[vout2];[vout1][vout2]vstack_vaapi=inputs=2:extra_hw_frames=10[out_v]" \
    -map '[out_v]' \
    -c:v h264_vaapi -global_quality 25 -profile:v:0 main \
    -map 0:a -c:a copy \
  -f mp4 -y  ${SCRIPT_DIR}/out.mkv
