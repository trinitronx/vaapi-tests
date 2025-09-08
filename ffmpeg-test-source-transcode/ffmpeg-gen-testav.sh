#!/bin/sh
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
num_cpus=$(nproc --all | head -n1)
rand_seed=$(od -N 4 -t uL -An /dev/urandom | tr -d " ")

# GPU VAAPI Device
gpu_dev=/dev/dri/renderD129
# Whitenoise video settings
duration=10
#duration=19.050
size=1920x1080
audio_color=0 # see: ffmpeg -help filter=anoisesrc
# NOTE: Check GPU supported encoders: vainfo | grep VAEntrypointEncSlice
out_codec=hevc_vaapi # see: ffmpeg -encoders  | grep  _vaapi
#out_codec=h264_vaapi # see: ffmpeg -encoders  | grep  _vaapi
framerate=25

# Test Audio (alternating stereo L/R frequencies)
P=0.5
F1=261.626 # C4 (middle C)
F2=349.228 # F4 (middle F)
F1a=130.813 # C3
F2a=174.614 # F3
alpha=157

ffmpeg -report \
       -threads $num_cpus \
       -filter_threads $num_cpus \
       -filter_complex_threads $num_cpus \
       -init_hw_device vaapi=amd0:${gpu_dev} -hwaccel vaapi -hwaccel_output_format vaapi \
       -hwaccel_device amd0 \
       -filter_hw_device amd0 \
       -color_trc linear -color_range pc -color_primaries bt709 -colorspace rgb \
       -f lavfi  \
       -i "mandelbrot=size=${size}" -t $duration \
       -f lavfi  \
       -i "testsrc=d=${duration}:size=${size}:decimals=0" -t $duration \
       -filter_complex "[0]colorkey=color=0xef80e0:similarity=0.5:blend=0.0,format=nv12,hwupload[v0]; [1]boxblur,format=nv12,hwupload[v1]; [v1][v0]vstack_vaapi[v3]; [v3]scale_vaapi[vout]" -t $duration \
       -f lavfi -i sine=$F1 -f lavfi -i sine=$F2 -f lavfi -i sine=$F1a -f lavfi -i sine=$F2a \
       -filter_complex "[2]volume=0:enable='lt(mod(t,$P),$P/2)'[a]; [3]volume=0:enable='lt(mod(t,$P),$P/2)'[a2]; [4]volume=0:enable='gte(mod(t,$P),$P/2)'[b]; [5]volume=0:enable='gte(mod(t,$P),$P/2)'[b2]; [a][b]join=inputs=2:channel_layout=stereo[c1]; [a2][b2]join=inputs=2:channel_layout=stereo[c2]; [c1][c2]join=inputs=2:channel_layout=stereo[aout]" -t $duration \
       -map "[vout]" -c:v $out_codec \
       -map "[aout]" -c:a ac3 \
       -y  ${SCRIPT_DIR}/out.${alpha}.mp4

#       -i "testsrc2=d=${duration}:size=${size}:alpha=${alpha}" -t $duration \
#       -vf "[vout]format=nv12,hwupload,scale_vaapi" \
#       -map "[vout]" -c:v $out_codec \
#
#       -filter_complex "[0]vectorscope=mode=1[v0]; [1]boxblur[v1]; [v0][v1]overlay[v3]; [v3]format=nv12,hwupload,scale_vaapi[vout]" -t $duration \

