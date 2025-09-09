---
title:      "FFmpeg and How to Use it Wrong"
subtitle:   "Streaming / Transcoding Tips & Tricks"
author:     "James Cuzella"
date:       "2023-06-21"
lang:       "en-EN"
---

Streaming / Transcoding Tips & Tricks
=====================================

- [FFmpeg and How to Use it Wrong][1]
  - 2-pass Encoding: Find Better Bitrate first, then Transcode

        # FPS should be specified as fractional form for accuracy:
        
        # Alternatively, fps can be probed using mediainfo (or perhaps ffprobe?)
        mediainfo $inputfile > info.tmp
        fps=$(cat info.tmp | grep Frame | grep [Rr]ate | grep -v [Mm]ode | cut -d ":" -f2 | tr -d " fps" | head -1)
        # e.g.:  fps=24000/1001  for 23.976fps (NTSC film)
        
        ffmpeg -i $inputfile $scan -pix_fmt $colorspace -vf "crop=$w1:$h1:$x1:$y1,scale=$fixedwidth:$fixedheight" -vsync 1 -sn -map $vtrack -r $fps -threads 0 -vcodec libx264 -b:v:$vtrack $averagevideobitrate -bufsize $buffer -maxrate $maximumvideobitrate -minrate $minimumvideobitrate -an -pass 1 -preset $newpreset -profile:v $defaultprofile -g $gop $tune -sc_threshold 0 -map_metadata -1 -f mp4 -y $outputfile-video.mp4

        ffmpeg -i $inputfile $scan -pix_fmt $colorspace -vf "crop=$w1:$h1:$x1:$y1,scale=$fixedwidth:$fixedheight" -vsync 1 -sn -map $vtrack -r $fps -threads 0 -vcodec libx264 -b:v:$vtrack $averagevideobitrate -bufsize $buffer -maxrate $maximumvideobitrate -minrate $minimumvideobitrate -an -pass 2 -preset $newpreset -profile:v $defaultprofile -g $gop $tune -sc_threshold 0 -map_metadata -1 -f mp4 -y $outputfile-video.mp4

- [How to Calculate VMAF with FFmpeg and Node.js: Visualizing Results in a Graph][2]
  - [local markdown][3]  - VMAF = Video Multi-Method Assessment Fusion (VMAF) is a metric developed by Netflix to evaluate video quality by combining several algorithms.
  - In this post, the author shows how to calculate VMAF using FFmpeg + Node.js TypeScript and to visualize the results in a graph.
- [Dear Netflix: Detecting Transcode Values][4]
  - In this post, the author shows how to detect source video framerate, interlaced, etc...
  - Then, how to use FFmpeg + Node.js to transcode properly.
- [Splitting a video with ffmpeg. The great mystical, magical video tool.🧙 by Taylor Dawson][5]
  - How to split a video evenly into discrete `n` second chunks without choppy, broken, or blank videos. 😎
  - **TLDR;**

        ffmpeg -i input.mp4 -c:v libx264 -crf 22 -map 0 -segment_time N -reset_timestamps 1 -g XX -sc_threshold 0 -force_key_frames “expr:gte(t,n_forced*N)” -f segment output%03d.mp4

    - `XX` — Number of frames
    - `N` — Number of seconds

- [Fancy Filtering Examples][6]
  - Contents
    - Video
      - cellauto
      - life
      - mandelbrot
      - gradients
      - mirror effect
      - video channel separation effect with lut filter
      - histogram & waveform
      - vectorscope & waveforms
      - waveform
      - waveform with envelope
      - more waveforms and vectorscope
      - datascope
    - Audio
      -  aevalsrc
      - showwaves and showspectrum
      - showspectrum
      - avectorscope
      - showcqt
      - showspectrumpic
      - showcwt
- [ffmpeg: chain of multiple `filter_complex`, re-using intermediate output stream][7]
  - **Question:** How can I apply two `filter_complex` commands sequentially?
  - **Answer:**
    - You have to use the split filter to duplicate the input stream.
    - Example:

          [...] split [crop1][crop2];
          [crop1] crop=960:960:24:1055 [out1];
          [crop2] crop=960:960:1056:1062 [out2]



[1]: https://videoblerg.wordpress.com/2017/11/10/ffmpeg-and-how-to-use-it-wrong/
[2]: https://levelup.gitconnected.com/how-to-calculate-vmaf-with-ffmpeg-and-node-js-visualizing-results-in-a-graph-a25501eba887
[3]: ./20230621-How%20to%20Calculate%20VMAF%20with%20FFmpeg%20and%20Node.js_%20Visualizing%20Results%20in%20a%20Graph-Mehran-Level%20Up%20Coding--by%20Mehran%20-%20Published%20in%20Level%20Up%20Coding.%204%20min%20read.%20Apr%2016.md
[4]: https://videoblerg.wordpress.com/2016/01/08/dear-netflix-2/
[5]: https://medium.com/@taylorjdawson/splitting-a-video-with-ffmpeg-the-great-mystical-magical-video-tool-%EF%B8%8F-1b31385221bd
[6]: http://trac.ffmpeg.org/wiki/FancyFilteringExamples
[7]: https://stackoverflow.com/questions/34338673/ffmpeg-chain-of-multiple-filter-complex-re-using-intermediate-output-stream
