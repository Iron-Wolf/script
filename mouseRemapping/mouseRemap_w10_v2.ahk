#Requires AutoHotkey v2.0 ; script only tested with V2.0

; +-------------+
; | DESCRIPTION |
; +-------------+
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


; +--------------+
; | TROUBLESHOOT |
; +--------------+
; SendMode Input
; --------------
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
; Those problems are resolved with the "Click" command.
;
; Shift click
; -----------
; Old code used to detect the state of the SHIFT button.
; This code is not needed after all, we keep it 
; for futur reference (if needed).
;
;  if (GetKeyState("Shift", "P")) {
;    Click, WheelRight
;  }


; +-------+
; | SETUP |
; +-------+
;#Warn  ; Enable warnings to assist with detecting common errors.

; help for debug
; -------------
;ListVars                    ; debug window
;MsgBox(You pressed mouseUp) ; message box

; VARIABLES
; ---------
autoScrollSleep := 150 ;time before auto scroll (milliseconds)
autoScrollInterval := 50 ;use it to control scroll speed (milliseconds)
keepLoopDown := 0
keepLoopUp := 0

; +------+
; | MAIN |
; +------+

; Details : 
;   this function execute a scroll when the FIRSTACTION button
;   is pressed.
; Parameters :
;   firstAction : primary action to execute (the scroll direction)
;   keepLoop :    reference to a boolean that stop the WHILE loop
; Notes :
;   Click function does not support "expression" so variables must be
;   enclosed in percents signs
scrollFunction(firstAction, scrollSleep, scrollInterval) {
	global keepLoopDown
	global keepLoopUp
	
    MouseClick(firstAction)
	sleep scrollSleep

    ; wait long enough to trigger auto scroll
    Loop 10 {
        ;if (!keepLoopDown || !keepLoopUp) {
        ;    return
        ;}
        ; use high-performance integer division (//)
        ;sleep scrollSleep//10
    }
	
    while (keepLoopDown || keepLoopUp) {
        MouseClick(firstAction)
        sleep scrollInterval
    }
}

; Mouse Down
; ----------
; Bind XButton1 (4th mouse button) to nothing.
; Allows us to override his default behaviour with a vertical scroll.
XButton1::
; shift
+XButton1::
; ctrl
^XButton1::
{
	global keepLoopDown := 1
    scrollFunction("WheelDown", autoScrollSleep, autoScrollInterval)
}

XButton1 up::
+XButton1 up::
^XButton1 up::
{
    ; stop auto scroll when released (button is UP)
    global keepLoopDown := 0
}


; Mouse Up
; --------
; Bind XButton2 (5th mouse button) to nothing.
; Allows us to override his default behaviour with a vertical scroll.
XButton2::
; shift
+XButton2::
; ctrl
^XButton2::
{
	global keepLoopUp := 1
    scrollFunction("WheelUp", autoScrollSleep, autoScrollInterval)
}

XButton2 up::
+XButton2 up::
^XButton2 up::
{
    ; stop auto scroll when released (button is UP)
    global keepLoopUp := 0
}


Esc::ExitApp  ; Exit script with Escape key
