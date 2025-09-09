---
title:      "How to Calculate VMAF with FFmpeg and Node.js: Visualizing Results in a Graph"
subtitle:   "by Mehran - Published in Level Up Coding. 4 min read. Apr 16"
author:     "James Cuzella"
date:       "2023-06-21"
lang:       "en-US"
---

source: https://levelup.gitconnected.com/how-to-calculate-vmaf-with-ffmpeg-and-node-js-visualizing-results-in-a-graph-a25501eba887

# How to Calculate VMAF with FFmpeg and Node.js: Visualizing Results in a Graph

In video streaming, assessing video quality is of utmost importance. Video Multi-Method Assessment Fusion (VMAF) is a metric developed by Netflix to evaluate video quality by combining several algorithms. FFmpeg is a powerful open-source tool for processing video and audio files. In this post, I will show you how to calculate VMAF using FFmpeg and Node.js TypeScript and visualize the results in a graph.

# Prerequisites

Before diving into the code, make sure you have the following tools installed and set up:

- Node.js and npm (https://nodejs.org/)
- FFmpeg with VMAF support (https://ffmpeg.org/download.html)
- A new Node.js TypeScript project (https://www.typescriptlang.org/)

# Calculating VMAF using FFmpeg

In this step, we will create a function to calculate VMAF using FFmpeg. We will execute a command line to calculate VMAF using FFmpeg and explain the essential flags and parameters. First, let's import the required modules and create a function to calculate VMAF:

import { exec } from 'child_process'

    function calculateVMAF(referenceVideo: string, encodedVideo: string): Promise<string> {
      return new Promise((resolve, reject) => {
        const command = `ffmpeg -i ${ referenceVideo } -i ${ encodedVideo } -filter_complex "[0:v]scale=1280:720:flags=lanczos+full_chroma_inp+full_chroma_int[ref];[1:v]scale=1280:720:flags=lanczos+full_chroma_inp+full_chroma_int[encoded];[ref][encoded]libvmaf=model='path=/usr/local/share/libvmaf/model/vmaf_v0.6.1.json:log_fmt=json:log_path=vmaf-log.json'" -f null -`
        exec(command, (error, stdout, stderr) => {
          if (error) {
            reject(error)
          } else {
            resolve(stdout)
          }
        })
      })
    }

### *A few hints about the FFMPEG command*

1. You have to install the latest version of FFMPEG that supports libvmaf lib.
2. You have to find the VMAF model path on your machine and pass it to the command; in this case, I used MAC, and the path to the model is:

    path=/usr/local/share/libvmaf/model/vmaf_v0.6.1.json

3. VMAF model is a trained model by NETFLIX used by libvmaf lib during the process.

4. In some cases, the input video (original) and output videos (ABR — transcoded videos) may have different dimensions (height and width). To accurately calculate the VMAF score in such instances, it's necessary to scale the videos to the exact dimensions. As you can see, this is part of the FFMPEG command.

    scale=1280:720

### *Reading VMAF results*

Now that we have calculated the VMAF scores, we need to read the results from the output JSON file. We will parse the JSON data and extract the VMAF scores for each frame:

    import * as fs from 'fs'
    
    async function readVMAFScores(): Promise<number[]> {
      const data = await fs.promises.readFile('vmaf-log.json', 'utf-8')
      const jsonData = JSON.parse(data)
      const frames = jsonData.frames
    
      const scores = frames.map((frame: any) => frame.metrics.vmaf)
      return scores
    }

The `readVMAFScores` function reads the 'vmaf-log.json' file and parses its content. It then extracts the VMAF scores for each frame and returns them as an array of numbers.

### *Visualizing VMAF scores in a graph*

To visualize the VMAF scores in a graph, we will use the Chart.js library for Node.js. First, install the 'chartjs-node-canvas' package using npm:

    npm install chartjs-node-canvas

Next, create a function to generate a chart with the VMAF scores:


    import { ChartJSNodeCanvas } from 'chartjs-node-canvas';
    
    async function generateVMAFGraph(vmafScores: number[]): Promise<void> {
      const chartJSNodeCanvas = new ChartJSNodeCanvas({ width: 800, height: 600 });
      const data = {
        labels: vmafScores.map((_, index) => index),
        datasets: [
          {
            label: 'VMAF Score',
            data: vmafScores,
            borderColor: 'rgba(75, 192, 192, 1)',
            borderWidth: 1,
          },
        ],
      };
    
      const configuration = {
        type: 'line',
        data: data,
        options: {
          scales: {
            y: {
              beginAtZero: true,
            },
          },
        },
      };
    
      const image = await chartJSNodeCanvas.renderToBuffer(configuration);
      await fs.promises.writeFile('vmaf-graph.png', image);
    }

The `generateVMAFGraph` function takes an array of VMAF scores as input and uses the Chart.js library to create a line chart. The function configures the chart with labels for each frame, VMAF scores as the data, and sets the y-axis to begin at zero. It then renders the chart to a buffer and saves the resulting image as 'vmaf-graph.png.'

### *Running the script*

Now that we have our functions for calculating VMAF, reading the results, and generating a graph, we can create a main function to run these tasks sequentially:

    async function main() {
      const referenceVideo = 'path/to/reference-video.mp4';
      const encodedVideo = 'path/to/encoded-video.mp4';
    
      await calculateVMAF(referenceVideo, encodedVideo);
      const vmafScores = await readVMAFScores();
      await generateVMAFGraph(vmafScores);
    
      console.log('VMAF graph generated: vmaf-graph.png');
    }
    
    main()
      .catch(error => {
        console.error('An error occurred:', error);
      });

The `main` function first calls `calculateVMAF` with the reference and encoded videos, then reads the VMAF scores using `readVMAFScores`. Finally, it generates a graph `generateVMAFGraph` and outputs a message indicating the graph has been generated.

### *Conclusion*

In this post, we demonstrated how to calculate VMAF using FFmpeg and Node.js TypeScript and visualize the results in a graph. This method allows a better understanding of video quality and how different encoding settings impact it. Visualizing VMAF scores in a graph allows you to compare various encoding parameters and optimize video streaming quality easily. Feel free to experiment with different encoding settings and analyze their impact on VMAF scores to achieve the best results for your use case.

## Level Up Coding

Thanks for being a part of our community! Before you go:

    👏 Clap for the story and follow the author 👉
    📰 View more content in the Level Up Coding publication
    💰 Free coding interview course ⇒ View Course
    🔔 Follow us: Twitter | LinkedIn | Newsletter

🚀👉 Join the Level Up talent collective and find an amazing job


