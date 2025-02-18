#Requires Autohotkey v2.0

; +-------------+
; | DESCRIPTION |
; +-------------+
; This script is extracted from the "ergol_nomade.zip",
; released here : https://github.com/Nuclear-Squid/ergol/releases

; <COMPILER: v1.1.37.01>
Persistent
InstallKeybdHook()
#SingleInstance force
#MaxThreadsBuffer
#MaxThreadsPerHotkey 3
A_MaxHotkeysPerInterval := 300
#MaxThreads 20
SendMode("Event")
SetKeyDelay(-1)
; V1toV2: Removed SetBatchLines, -1
ProcessSetPriority("R")
;REMOVED StringCaseSense, On

global Active := True

RAlt & Alt::
Alt & RAlt::
{
    global Active
    Active := !Active
    return
}
#HotIf Active

global DeadKey := ""
SendChar(char) {
    if GetKeyState("CapsLock", "T") {
        if (StrLen(char) == 6) {
            char := Chr("0x" SubStr(char, 3, 4))
        }
        char := StrUpper(char)
    }
    Send("{" char "}")
}

DoTerm(base:="") {
    global DeadKey
    term := SubStr(DeadKey, 2, 1)
    Send("{" term "}")
    SendChar(base)
    DeadKey := ""
}

DoAction(action:="") {
    global DeadKey
    if (action == "U+0020") {
        Send("{SC39}")
        DeadKey := ""
    }
    else if (StrLen(action) != 2) {
        SendChar(action)
        DeadKey := ""
    }
    else if (action == DeadKey) {
        DoTerm(SubStr(DeadKey, 2, 1))
    }
    else {
        DeadKey := action
    }
}

SendKey(base, deadkeymap) {
    if (!DeadKey) {
        DoAction(base)
    }
    else if (deadkeymap.Has(DeadKey)) {
        DoAction(deadkeymap[DeadKey])
    }
    else {
        DoTerm(base)
    }
}

SC02::SendKey("U+0031", Map("**", "U+201e", "*^", "U+00b9", "*ˇ", "U+2081"))
+SC02::SendKey("U+20ac", Map("**", "U+201a"))

