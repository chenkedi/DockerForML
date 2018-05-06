#!/usr/bin/env bash
mkdir /mnt/docker
cp ../python3-cpu-avx/Anaconda3-5.0.1-Linux-x86_64.sh ./
cp ../python3-cpu-avx/opencv-3.3.1.zip ./
cp ../python3-cpu-avx/opencv_contrib-3.3.1.zip ./

# build docker image
nvidia-docker build -t="iot-data/python3-gpu" .