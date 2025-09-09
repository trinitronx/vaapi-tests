#!/bin/sh
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

num_cpus=$(nproc --all | head -n1)

#input_testfile=${SCRIPT_DIR}/10401_20230422043000.ts  # Crashes ~35mins into video
input_testfile=${SCRIPT_DIR}/10401_20230422043000.ffmpeg-crash-testcase.1_30.ts  # Crashes ~1min 20-30sec into video

# Shorter testcase produced via:
#   ffmpeg  -i 'concat:/mythtv/recordings/10401_20230422043000.ts' -ss 00:00:00 -t 00:01:30 -c copy  ./10401_20230422043000.ffmpeg-crash-testcase.1_30.ts
# Note: ffmpeg lists more CRC errors while transcoding with the shorter testcase, but it's reliable to reproduce & smaller file

ffmpeg -report \
  -fflags +discardcorrupt+genpts -err_detect aggressive -threads $num_cpus \
  -init_hw_device vaapi=amd0:/dev/dri/renderD129 -hwaccel vaapi -hwaccel_output_format vaapi \
  -hwaccel_device amd0 \
  -filter_hw_device amd0 \
  -i $input_testfile \
  -vf 'format=vaapi,hwupload,scale_vaapi=w=1280:h=720' \
  -map 0:0 -c:v hevc_vaapi \
  -global_quality 25 -bf 3 -refs 2 \
  -profile:v:0 main -async_depth:v:0 10 -rc_mode:v:0 auto -b_depth:v:0 1 \
  -map 0:a -c:a ac3 -strict strict \
  -f mp4  -y  ${SCRIPT_DIR}/out.hevc.mp4
