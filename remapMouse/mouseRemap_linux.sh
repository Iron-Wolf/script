#!/bin/bash
# http://www.remycorthesy.fr/montpellier/symboles-codes-caracteres-ascii-iso.htm
#
# ==================================================================
#                        /!\ WARNGING /!\
#    THIS SCRIPT IS A MIXTURE OF THINGS THAT DON'T WORK WELL.
#    IT IS NOT MAINTAINED AND HAS NOT BEEN BATTLE-TESTED.
#    USE AT YOUR OWN DISCRETION.
# ==================================================================
#
#
# Basic explanation : https://askubuntu.com/a/492745
# get device ID :   xinput
# list all button : xinput list <ID>
# see key press :   xinput test <ID>
# get mapping :     xinput --get-button-map <ID>
# get mouse ID :    xinput --list | grep -i -m 1 'mouse' | grep -o 'id=[0-9]\+' | grep -o '[0-9]\+'
#
# +--------------+
# | DEPENDENCIES |
# +--------------+
# xdotool
#
#
# Sample code with windows :
# eval window under mouse cursor (set WINDOW variable)
#eval $(xdotool getmouselocation --shell)
# send keystroke to that window
#xdotool key --window $WINDOW Up

# disable default mouse behaviour and
# control all from this script
mouseId='12'
#mouseMapping='1 2 3 4 5 6 7 5 4' # side-forward(9) <> wheel-up(4) / side-back <> wheel-down
mouseMapping='1 2 3 4 5 6 7 0 0' # disable side button
#mouseMapping='1 2 3 4 5 6 7 8 9' # default map
xinput set-button-map $mouseId $mouseMapping

# +------+
# | MAIN |
# +------+
autoScrollStep=10 # time before auto scroll
autoScrollInterval=30 # use it to control auto scroll speed (milliseconds)

# convert to milliseconds (doesn't used)
#autoScrollInterval=`echo "scale=2; $autoScrollInterval/1000" | bc -l`


# infinite loop
while true; do
  # wait mouse click to lower CPU usage, 
  # but doesn't go beyond 0.1s interval
  # -g : exit on change
  # -n : interval
  # -p : precise mode (maybe useless)
  #watch -g -n 0.1 -p 'xinput --query-state 12 | grep "button\[[89]\]=down"'
  
  # +-------------+
  # | FIRST CLICK |
  # +-------------+
  startAutoScroll=false
  
  sideBack=`xinput --query-state $mouseId | grep "button\[8\]=down"`
  # test if variable is set
  if [ "$sideBack" ]; then
    # button is held down
    xdotool click 5 # down
    startAutoScroll=true
  fi
  sideFront=`xinput --query-state $mouseId | grep "button\[9\]=down"`
  # test if variable is set
  if [ "$sideFront" ]; then
    # button is held down
    xdotool click 4 # up
    startAutoScroll=true
  fi
  
  # +-------------+
  # | AUTO SCROLL |
  # +-------------+
  if $startAutoScroll; then
    # Loop used to "pause" the script before auto scoll.
    # We check if the button is actually held down (to
    # determine if this is a TRUE held down gesture all along)
    for i in `seq 1 $autoScrollStep`; do
	    side=`xinput --query-state $mouseId | grep "button\[[89]\]=down"`
      if [ "$side" ]; then
        echo "" > /dev/null
      else
        break
      fi
    done

    sideBack=`xinput --query-state $mouseId | grep "button\[8\]=down"`
    while [ "$sideBack" ]; do
      # set "repeat" flag to control "delay"
      xdotool click \
        --repeat 1 \
        --delay $autoScrollInterval \
        5 # scroll down
      
      # re-evaluate loop condition
      sideBack=`xinput --query-state $mouseId | grep "button\[8\]=down"`
    done
    
    sideFront=`xinput --query-state $mouseId | grep "button\[9\]=down"`
    while [ "$sideFront" ]; do
      # set "repeat" flag to control "delay"
      xdotool click \
        --repeat 1 \
        --delay $autoScrollInterval \
        4 # scroll up
      
      # re-evaluate loop condition
      sideFront=`xinput --query-state $mouseId | grep "button\[9\]=down"`
    done
  fi

  # minimum sleep between each loop
  # to lower CPU footprint
  sleep 0.05
done



