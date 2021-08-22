#!/usr/bin/env python3 
# -*- coding: utf-8 -*- 

"""
Launch with :
  sudo ./mouseRemap_linux.py


Dependencies
Install pip :
  sudo apt install python3-pip

Install mouse (repo : https://github.com/boppreh/mouse
  sudo pip install mouse
"""

import mouse
import subprocess
import re #regex

MOUSE_ID='12'
MOUSE_MAPPING='1 2 3 4 5 6 7 0 0'
AUTO_SCROLL_STEP=10 # time before auto scroll
AUTO_SCROLL_INTERVAL=30 # control auto scroll speed (milliseconds)


"""
Get the actual physical state
of the given button
"""
def butonState(button):
  # for python < 3.7
  #result = subprocess.run(["xinput", "--query-state", "12"], stdout=subprocess.PIPE, universal_newlines=True)
  # for python >= 3.7
  #result = subprocess.run(["xinput", "--query-state", "12"], capture_output=True, universal_newlines=True)
  #print("r:",result.stdout)

  # captured output is returned as bytes
  # use "universal_newlines=True" ("text=True" for python >= 3.7)
  # to capture as text
  result = subprocess.check_output(["xinput", "--query-state", MOUSE_ID], 
    universal_newlines=True)
  
  regex = re.search('button\[{0}\]=down'.format(button), result)
  if regex:
    #print("regex:", regex.group(0))
    return True
  else:
    return False

"""

"""
def scrollFunction(wheelDir, buttonNum):
  #mouse.wheel(-1) # <- don't work because desactivated ?
  subprocess.run(["xdotool", "click", wheelDir])

  # Loop used to "pause" the script before auto scoll.
  # We check if the button is actually held down (to
  # determine if this is a TRUE held down gesture all along)
  for i in range(AUTO_SCROLL_STEP):
    state=butonState(buttonNum)
    if state:
      pass
    else:
      return
  
  keepLoop=butonState(buttonNum)
  while keepLoop:
    # set "repeat" flag to control "delay"
    subprocess.run(["xdotool", "click", 
      "--repeat", "1", 
      "--delay", str(AUTO_SCROLL_INTERVAL),
      wheelDir])
    keepLoop=butonState(buttonNum)


# +------+
# | MAIN |
# +------+
def main(): 
  # remove all registered events, just to be sure
  mouse.unhook_all()

  # Disable default mouse behaviour and
  # control all from this script.
  # Use "shell=True" to pass a single string because
  # the "run" command escape the arguments.
  subprocess.run(["xinput set-button-map {0} {1}".format(MOUSE_ID, MOUSE_MAPPING)], shell=True)
  subprocess.run(["xinput", "--get-button-map", MOUSE_ID])

  mouse.on_button(scrollFunction,("5","8"),'x','down')
  mouse.on_button(scrollFunction,("4","9"),'x2','down')


# enable use of the script as an imported module
if __name__ == "__main__": 
	main()

input('wait...\n')






