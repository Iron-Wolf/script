; +-------------+
; | DESCRIPTION |
; +-------------+
;
; This script remap some mouse buttons to perform scroll action instead.
; Motivation : a broken scroll wheel on my mouse.
;
; Remap config :
;   XButton1 (side button) -> scroll down
;   XButton2 (side button) -> scroll up
;
; Usage : - click on XButton1/2 trigger a scroll
;         - if button is held, the script wait a short period of time
;           then endlessly trigger an auto scroll in the same direction
;         - When the button is released, the scroll is stopped
;
;
; +--------------+
; | TROUBLESHOOT |
; +--------------+
; Initialy used "SendMode Input" but this buffer any input during the send action.
; This result in some buggy behaviour (auto scroll is triggered even though the button is
; physicaly released).
; Aditionnaly, "Send" has to be used in Blind mode to avoid releasing hotkeys (Ctrl/Shift/...)
; Example : Send {Blind}{WheelDown}
; 
; Without the "Blind" mode, we used to have strange behaviour with the "Shift" key :
;                ┌ press                         ┌ release
;   Sample : 0000100000000000111111011111111111110000000
;                 └────┬────┘      └ random "0" 
;               key is held, but "0" are returned anyway
;
; These problems are resolved with the "Click" command.

; +-------+
; | SETUP |
; +-------+
#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
;#Warn  ; Enable warnings to assist with detecting common errors.

; help for debug
; ~~~~~~~~~~~~~~
;ListVars                    ; debug window
;MsgBox, You pressed mouseUp ; message box

; VARIABLES
; ~~~~~~~~~
autoScrollSleep := 150 ;time before auto scroll (milliseconds)
autoScrollInterval := 50 ;use it to control scroll speed (milliseconds)

; +------+
; | MAIN |
; +------+

; Mouse Down
; ~~~~~~~~~~
; bind mouse4 to nothing : vertical scroll
XButton1::
; shift
+XButton1::
; ctrl
^XButton1::
	keepLoopDown := 1
	; physicaly read the "shift" state
	if (GetKeyState("Shift", "P")) {
		Click, WheelRight
	}
	else {
		Click, WheelDown
	}
	
	; wait long enough to trigger auto scroll
	Loop 10 {
		if (!keepLoopDown) {
			return
		}
		sleep 15
	}
	
	while (keepLoopDown) {
		if (GetKeyState("Shift", "P")) {
			Click, WheelRight
		}
		else {
			Click, WheelDown
		}
		sleep %autoScrollInterval%
	}
return

XButton1 up::
+XButton1 up::
^XButton1 up::
	; stop auto scroll when released (button is UP)
	keepLoopDown := 0
return


; Mouse Up
; ~~~~~~~~
; bind mouse5 to nothing : vertical scroll
XButton2::
; shift
+XButton2::
; ctrl
^XButton2::
	keepLoopUp := 1
	; physicaly read the "shift" state
	if (GetKeyState("Shift", "P")) {
		Click, WheelLeft
	}
	else {
		Click, WheelUp
	}
	
	; wait long enough to trigger auto scroll
	Loop 10 {
		if (!keepLoopUp) {
			return
		}
		sleep 15
	}
	
	while (keepLoopUp) {
		if (GetKeyState("Shift", "P")) {
			Click, WheelLeft
		}
		else {
			Click, WheelUp
		}
		sleep %autoScrollInterval%
	}
return

XButton2 up::
+XButton2 up::
^XButton2 up::
	; stop auto scroll when released (button is UP)
	keepLoopUp := 0
return
