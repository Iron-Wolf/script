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
; SendMode("Event")
; --------------
; By default, AHK does some stuff behind the scene to smooth out messy scripts.
; This is good for most use cases, but we are not in a safe zone here.
; As such, we must find and disable theses unwanted behaviours (https://www.autohotkey.com/docs/v2/lib/SendMode.htm) :
;  - SendInput    : "it buffers any physical keyboard or mouse activity during the send"
;    - fix with SendMode("Event")
;  - WheelDown/Up : "The delay between mouse clicks is determined by SetMouseDelay"
;    - fix with SetMouseDelay(-1)
;
; Here is the details of the "bug" :
;  - during the endless auto-scroll logic, we physically release the side button
;  - the OS function is triggered (a tab switch in the browser, for example)
;    - this should not be triggered
;  - as we "escaped" the script, we are in an infinite scrolling loop
;    - in this state, the "GetKeyState("XButton1", "P")" is buggy (return 1 instead of 0, as the button is not held)
;    - the "KeyWait" is never reached
;    - a "$XButton2 up::" block will also never be reached either


; +-------+
; | SETUP |
; +-------+
;#Warn                ; Enable warnings to assist with detecting common errors.
#SingleInstance Force ; Skips the dialog box and replaces the old instance automatically.
Persistent            ; Will not exit automatically (you can use its tray icon to open the script)
SendMode("Event")     ; doc here : https://www.autohotkey.com/docs/v2/lib/Send.htm
SetMouseDelay(-1)     ; disable the default delay between click, we handle it already

; help for debug
; -------------
;ListVars             ; debug window
;MsgBox("a msg")      ; message box

; VARIABLES
; ---------
asDelay := 150        ; time before starting auto-scroll
asSpeed := 30         ; during auto-scroll : time (milliseconds) to wait between each scroll


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
    Sleep(asDelay)
    SetTimer(scrollDwn, asSpeed)
    
    ; wait release
    KeyWait("XButton1")
    SetTimer(scrollDwn, 0)

    ; +------------------------+
    ; | ↓↓↓ EMERGENCY CODE ↓↓↓ |
    ; +------------------------+
    ;scrollDwn()
    ;
    ;; wait before fixed auto-scroll
    ;Sleep(asDelay)
    ;if (!GetKeyState("XButton1", "P")) {
    ;    return
    ;}
    ;
    ;BlockInput(true)
    ;Loop 10 {
    ;    scrollDwn()
    ;	Sleep(asSpeed)
    ;}
    ;BlockInput(false)
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
    Sleep(asDelay)
    SetTimer(scrollUp, asSpeed)
    
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
