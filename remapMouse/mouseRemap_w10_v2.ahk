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
; Maybe a finaly working solution.
; Using loops with Sleep(1) kind of work.
; This call also seems to work (but not cross platform ?) : DllCall("Sleep", "UInt", 150)
;
; The previous design with a Sleep(150) was borked.


; +-------+
; | SETUP |
; +-------+
;#Warn  ; Enable warnings to assist with detecting common errors.
#SingleInstance Force
Persistent ; Will not exit automatically (you can use its tray icon to open the script)

; help for debug
; -------------
;ListVars                      ; debug window
;MsgBox("You pressed mouseUp") ; message box

; VARIABLES
; ---------
autoScrollSleep := 10 ;time before auto-scroll
autoScrollInterval := 50 ;use it to control scroll speed (milliseconds)
keepScroll := false


; +------+
; | MAIN |
; +------+
scrollUp() {
    MouseClick("WheelUp")
}
scrollDwn() {
    MouseClick("WheelDown")
}

; Mouse Down
; ----------
; Bind XButton1 (4th mouse button) to nothing.
; Allows us to override his default behaviour with a vertical scroll.
$XButton1::
$+XButton1::
$^XButton1::
{
	; first press
	scrollDwn()
	
	; wait before auto-scroll
	Loop autoScrollSleep {
        Sleep(1)
    }
	SetTimer(scrollDwn, autoScrollInterval)
	
	; wait release
	KeyWait("XButton1")
	SetTimer(scrollDwn, 0)
}

; Mouse Up
; --------
; Bind XButton2 (5th mouse button) to nothing.
; Allows us to override his default behaviour with a vertical scroll.
$XButton2::
$+XButton2::
$^XButton2::
{
	; first press
	scrollUp()
	
	; wait before auto-scroll
	Loop autoScrollSleep {
        Sleep(1)
    }
	SetTimer(scrollUp, autoScrollInterval)
	
	; wait release
	KeyWait("XButton2")
	SetTimer(scrollUp, 0)
}


; Exit script with Ctrl+Alt+E
^!e::
{
    ; work with "persistent" mode because it will terminate the app (and not the Thread)
    ExitApp 
}
