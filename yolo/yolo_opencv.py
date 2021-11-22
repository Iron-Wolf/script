#############################################
# Object detection - YOLO - OpenCV
# Author : Arun Ponnusamy   (July 16, 2018)
# Website : https://www.arunponnusamy.com/yolo-object-detection-opencv-python.html
############################################
#
# Description : 
#  YOLO implementation in python, using OpenCV deep neural network module.
#
#  You will need a Yolo Weight file : https://pjreddie.com/media/files/yolov3.weights
#

import cv2
import argparse
import numpy as np

# handle command line arguments
ap = argparse.ArgumentParser()
ap.add_argument('-i', '--image', required=True,
                help = 'path to input image')
ap.add_argument('-c', '--config', required=True,
                help = 'path to yolo config file')
ap.add_argument('-w', '--weights', required=True,
                help = 'path to yolo pre-trained weights')
ap.add_argument('-cl', '--classes', required=True,
                help = 'path to text file containing class names')
ap.add_argument("-cf", "--confidence", type=float, default=0.5,
                help="minimum probability to filter weak detections")
ap.add_argument("-t", "--threshold", type=float, default=0.4,
	              help="threshold when applying non-maxima suppression")
args = ap.parse_args()


# determine only the *output* layer names that we need
def get_output_layers(net):
    layer_names = net.getLayerNames()
    output_layers = [layer_names[i[0] - 1] for i in net.getUnconnectedOutLayers()]
    return output_layers

# draw a bounding box and label on the image
def draw_prediction(img, class_id, confidence, x, y, x_plus_w, y_plus_h):
    label = str(classes[class_id])
    color = COLORS[class_id]
    cv2.rectangle(img, (x,y), (x_plus_w,y_plus_h), color, 2)
    cv2.putText(img, label, (x-10,y-10), cv2.FONT_HERSHEY_SIMPLEX, 0.5, color, 2)


# read input image and get its width and height
image = cv2.imread(args.image)
Width = image.shape[1]
Height = image.shape[0]

# crop image with numpy slicing
y=0 # coordinate from top
x=0 # coordinate from left
(h, w) = (100, 200)
crop = image[y:y+h, x:x+w].copy() 

# remove part of the image (draw a beautiful black box)
#img = cv2.rectangle(
#  image, # image object on which to draw
#  (250,30), # coordinates of the vertex at the top left (x, y)
#  (450,200), # coordinates of the lower right vertex (x, y)
#  (0,0,0), # stroke color in BGR (not RGB, be careful)
#  cv2.FILLED) # stroke thickness, in pixels (negative values mean filled rectangle)


# read class names from text file
classes = None
with open(args.classes, 'r') as f:
    classes = [line.strip() for line in f.readlines()]

# generate different colors for different classes 
COLORS = np.random.uniform(0, 255, size=(len(classes), 3))
# reads pre-trained model and config file and creates the network
net = cv2.dnn.readNet(args.weights, args.config)
# create input blob 
blob = cv2.dnn.blobFromImage(image, 1/255.0, (416,416), (0,0,0), True, crop=False)
# set input blob for the network
net.setInput(blob)

# run inference through the network and gather predictions from output layers.
# If we don’t specify the output layer names, by default, 
# it will return the predictions only from final output layer. 
# Any intermediate output layer will be ignored.
outs = net.forward(get_output_layers(net))

class_ids = [] # the detected object’s class name
confidences = [] # the confidence value 
boxes = [] # bounding boxes around the object

# loop over each of the layer outputs
for out in outs:
    # loop over each of the detections
    for detection in out:
        # extract the class ID and confidence (i.e., probability) of
        # the current object detection
        scores = detection[5:]
        class_id = np.argmax(scores)
        confidence = scores[class_id]
        # filter out weak predictions
        if confidence > args.confidence:
			      # scale the bounding box coordinates back relative to the
			      # size of the image, keeping in mind that YOLO actually
			      # returns the center (x, y)-coordinates of the bounding
			      # box followed by the boxes' width and height
            center_x = int(detection[0] * Width)
            center_y = int(detection[1] * Height)
            w = int(detection[2] * Width)
            h = int(detection[3] * Height)
			      # use the center (x, y)-coordinates to derive the top and
			      # and left corner of the bounding box
            x = center_x - w / 2
            y = center_y - h / 2
            # update our list
            class_ids.append(class_id)
            confidences.append(float(confidence))
            boxes.append([x, y, w, h])

# apply non-maxima suppression to suppress weak, overlapping bounding boxes
indices = cv2.dnn.NMSBoxes(boxes, confidences, args.confidence, args.threshold)

# loop over the indexes we are keeping
for i in indices.flatten():
    # extract the bounding box coordinates
    (x, y) = (boxes[i][0], boxes[i][1])
    (w, h) = (boxes[i][2], boxes[i][3])
    # draw on image
    label = str(classes[class_ids[i]])
    percent = confidences[i]*100
    print('object: ',  label, '(', percent, ')');
    draw_prediction(image, class_ids[i], confidences[i], round(x), round(y), round(x+w), round(y+h))

#cv2.imshow("object detection", image)
#cv2.waitKey()
    
cv2.imwrite("object-detection.jpg", image)
#cv2.destroyAllWindows()
