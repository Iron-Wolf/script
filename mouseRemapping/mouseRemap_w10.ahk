; +-------------+
; | DESCRIPTION |
; +-------------+
;

; +-------+
; | SETUP |
; +-------+
#NoEnv                      ; Recommended for performance and compatibility with future AutoHotkey releases.
;#Warn                       ; Enable warnings to assist with detecting common errors.
;SendMode Input              ; Recommended for new scripts due to its superior speed and reliability.
;SetWorkingDir %A_ScriptDir% ; Ensures a consistent starting directory.

; ~~~~~~~~~~~~~~
; help for debug
; ~~~~~~~~~~~~~~
;ListVars                    ; debug window
;MsgBox, You pressed mouseUp ; message box

; ~~~~~~~~~
; VARIABLES
; ~~~~~~~~~
autoScrollSleep := 150 ;time before auto scroll (milliseconds)
autoScrollInterval := 50 ;use it to control scroll speed (milliseconds)

; +------+
; | MAIN |
; +------+

; ~~~~~~~~~~
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


; ~~~~~~~~
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
	; stop auto scroll when released
	keepLoopUp := 0
return


