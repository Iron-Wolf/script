#!/usr/bin/python
import RPi.GPIO as GPIO
import time
import subprocess

# -------------
#  Description
# -------------
# This script allow us to use a physical switch to 
# power up/down the raspberry pi installed with Kodi.

# -----------------
#  Install Process
# -----------------
# Download GPIO package :
#  wget https://pypi.python.org/packages/source/R/RPi.GPIO/RPi.GPIO-0.5.11.tar.gz
#
# Untar the archive, then install :
#  tar -zxvf RPi.GPIO-0.5.11.tar.gz
#  cd RPi.GPIO-0.5.11; python setup.py install
#
# If needed, install these package :
#  apt install python-dev gcc python-pip

# --------------------
#  Start at boot time
# --------------------
# Edit /etc/rc.local file and add (before 'exit 0') :
#  python /home/osmc/shutdown.py


# we will use the pin numbering to match the pins on the Pi, instead of the
# GPIO pin outs (makes it easier to keep track of things)

GPIO.setmode(GPIO.BOARD)

# use the same pin that is used for the reset button
# (one button to rule them all!)
GPIO.setup(5, GPIO.IN, pull_up_down = GPIO.PUD_UP)

oldButtonState1 = True

while True:
  #grab the current button state
  buttonState1 = GPIO.input(5)

  # check to see if button has been pushed
  if buttonState1 != oldButtonState1 and buttonState1 == False:
    subprocess.call("shutdown -h now", shell=True, 
      stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    oldButtonState1 = buttonState1

    time.sleep(.1)
