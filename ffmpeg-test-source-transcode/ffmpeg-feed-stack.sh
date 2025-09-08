SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
num_cpus=$(nproc --all | head -n1)
# GPU VAAPI Device
gpu_dev=/dev/dri/renderD129

# NOTE: Check GPU supported encoders: vainfo | grep VAEntrypointEncSlice
out_codec=hevc_vaapi # see: ffmpeg -encoders  | grep  _vaapi
framerate=25
duration=19.050
size=1920x1080

# Given test feeds and labeled [a1], [b1]
ffmpeg -report \
       -threads $num_cpus \
       -filter_threads $num_cpus \
       -filter_complex_threads $num_cpus \
       -init_hw_device vaapi=amd0:${gpu_dev} -hwaccel vaapi -hwaccel_output_format vaapi \
       -hwaccel_device amd0 \
       -filter_hw_device amd0 \
       -f lavfi \
       -i "testsrc=d=${duration}:size=${size}:decimals=3" -t $duration \
       -f lavfi \
       -i "testsrc2=d=${duration}:size=${size}" -t $duration \
       -filter_complex \
               "[0]format=nv12,hwupload[hw0]; 
                [1]format=nv12,hwupload[hw1]; 
                      [hw1][hw0]vstack_vaapi,scale_vaapi=h=2304:force_original_aspect_ratio=1[c];  
                        [c]scale_vaapi[vout]" -t $duration \
       -map "[vout]" -c:v $out_codec \
       -y  ${SCRIPT_DIR}/out.mp4 

