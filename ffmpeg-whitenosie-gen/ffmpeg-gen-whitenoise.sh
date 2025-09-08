#!/bin/sh
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
num_cpus=$(nproc --all | head -n1)
rand_seed=$(od -N 4 -t uL -An /dev/urandom | tr -d " ")

# GPU VAAPI Device
gpu_dev=/dev/dri/renderD129
# Whitenoise video settings
duration=19.050
size=1920x1080
audio_color=0 # see: ffmpeg -help filter=anoisesrc
# NOTE: Check GPU supported encoders: vainfo | grep VAEntrypointEncSlice
#out_codec=hevc_vaapi # see: ffmpeg -encoders  | grep  _vaapi
out_codec=h264_vaapi # see: ffmpeg -encoders  | grep  _vaapi
framerate=25

ffmpeg -stats \
       -threads $num_cpus \
       -filter_threads $num_cpus \
       -init_hw_device vaapi=amd0:${gpu_dev} -hwaccel vaapi -hwaccel_output_format vaapi \
       -hwaccel_device amd0 \
       -filter_hw_device amd0 \
       -color_trc linear -color_range pc -color_primaries bt709 -colorspace rgb \
       -f rawvideo -video_size ${size} -pixel_format yuv420p -framerate $framerate \
       -i /dev/urandom -t $duration \
       -vf "format=nv12,hwupload,scale_vaapi" \
       -map 0:0 -c:v $out_codec \
       -filter_complex "anoisesrc=duration=${duration}:color=${audio_color}:seed=${rand_seed}[aout]" -t $duration \
       -map "[aout]" -c:a ac3 -y  ${SCRIPT_DIR}/out.mp4

#ffmpeg -report \
#       -threads $num_cpus \
#       -filter_threads $num_cpus \
#       -init_hw_device vaapi=amd0:/dev/dri/renderD129 -hwaccel vaapi -hwaccel_output_format vaapi \
#       -hwaccel_device amd0 \
#       -filter_hw_device amd0 \
#       -color_trc linear -color_range pc -color_primaries bt709 -colorspace rgb \
#       -f lavfi -i "nullsrc=s=1920x1080:duration=${d},geq=random(1)*255:128:128" -t $d \
#       -vf "format=nv12,hwupload,scale_vaapi" \
#       -map 0:0 -c:v hevc_vaapi \
#       -filter_complex "anoisesrc=duration=${d}:color=0:seed=${rand_seed}[aout]" -t $d \
#       -map "[aout]" -c:a ac3 -y  ${SCRIPT_DIR}/out.h264.mp4



## Color + Sound no accel
#ffmpeg -f rawvideo -video_size 1920x1080 -pixel_format yuv420p -framerate 25 -i /dev/urandom -ar 48000 -ac 2 -f s16le -i /dev/urandom -t 31 -b:a 256k out_color_sound.mp4

#       -vf "format=nv12,hwupload,scale_vaapi,hwmap=mode=read+write+direct,format=nv12,subtitles=filename='${SCRIPT_DIR}/sample.srt':charenc=ASCII,setpts=PTS -0/TB,hwmap" \
#       -vf "format=nv12|vaapi,hwupload,scale_vaapi=format=nv12,hwmap=mode=read+write+direct,subtitles=${SCRIPT_DIR}/sample.srt,hwmap" \
