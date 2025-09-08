# GPU VAAPI Device
gpu_dev=/dev/dri/renderD129

# Given test feeds and labeled [a1], [b1]
mpv --vaapi-device=${gpu_dev} \
    --vo=gpu-next \
    --hwdec=vaapi-copy \
    --lavfi-complex='[vid1]format=nv12|vaapi,hwupload[a];
                     [vid2]format=nv12|vaapi,hwupload[b];
                       [a][b]vstack_vaapi,scale_vaapi=h=2304:force_original_aspect_ratio=1[c]; 
                       [c]scale_vaapi[vo]' \
    --external-files='./vid2.mp4' \
    ./vid1.mp4

