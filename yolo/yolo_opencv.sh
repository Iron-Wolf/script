#!/bin/bash
#
# usage : yolo_opencv.sh [image_path...]
#
# This script process images with the YOLO model
# and the COCO dataset, using the neural network module of OpenCV
#
for img in $*; do  
  python3 yolo_opencv.py \
  --image $img \
  --config yolov3.cfg \
  --weights yolov3.weights \
  --classes yolov3.txt # COCO class labels our YOLO model was trained on
done

