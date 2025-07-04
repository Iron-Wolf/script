
; source script from : https://www.autohotkey.com/docs/v2/lib/ListView.htm#ExAdvanced

; Description :
;  - button with a calendar
;  - list view with user's running process
;    - simple clic to bring the process in front
;    - if window is already active, minimize it
;    - right clic for context menu

;MyGuiA := Gui()  ; Créer une fenêtre GUI.
;LV := MyGuiA.Add("ListView", "h300 w400", ["Icône & Processus", "Fenêtre"])
;ImageListID := IL_Create(20)  ; Créer une ImageList pour stocker les icônes.
;LV.SetImageList(ImageListID)
;for hwnd in WinGetList() {
;    if WinExist("ahk_id " hwnd) {
;        pid := WinGetPID(hwnd)
;        exePath := ProcessGetPath(pid)
;        title := WinGetTitle(hwnd)
;        
;        if exePath && title {
;            iconIndex := IL_Add(ImageListID, exePath, 1)  ; Ajouter l'icône du processus
;            LV.Add("Icon" . iconIndex, exePath, title)
;        }
;    }
;}
;MyGuiA.Show()


#SingleInstance Force
; use the screen to compute the mouse position
; (https://www.autohotkey.com/docs/v2/lib/CoordMode.htm)
CoordMode("Mouse", "Screen")

; Create a GUI window
MyGui := Gui("+OwnDialogs +Resize +ToolWindow")
MyGui.MarginX := 0
MyGui.MarginY := 0
MyGui.Opt("+AlwaysOnTop")
;MyGui.Opt("-Border")

; Create some buttons
;Brefresh := MyGui.Add("Button", "Default", "Refresh")
;Bswitch := MyGui.Add("Button", "x+5", "Switch View")

; Create the ListView and its columns via Gui.Add
LV := MyGui.AddListView("r3 w2000", ["ahkTitle", "ahkId", "ahkProcess"])
; For sorting, indicate that the column is an integer
LV.ModifyCol(2, "Integer")

; Create an ImageList so that the ListView can display some icons
ImageListID1 := IL_Create()
ImageListID2 := IL_Create(,, true)  ; A list of large icons to go with the small ones.

; Attach the ImageLists to the ListView so that it can later display the icons
LV.SetImageList(ImageListID1)
LV.SetImageList(ImageListID2)

; Apply control events
LV.OnEvent("Click", ActiveWin)
LV.OnEvent("ContextMenu", ShowContextMenu)
;Brefresh.OnEvent("Click", UpdateProcess)
;Bswitch.OnEvent("Click", SwitchView)
MyGui.OnEvent("Size", Gui_Size)
MyGui.OnEvent("Close", CloseApp)
MyGui.OnEvent("Escape", CloseApp)

; Create a popup menu to be used as the context menu
ContextMenu := Menu()
ContextMenu.Add("Open", ContextOpenOrProperties)
ContextMenu.Add("Properties", ContextOpenOrProperties)
ContextMenu.Add("Clear from ListView", ContextClearRows)
ContextMenu.Default := "Open"  ; Make "Open" a bold font to indicate that double-click does the same thing.

; Display the window
MyGui.Show("x0 y-30")
UpdateProcess()
SwitchView()
global globActiveWinID := -1

UpdateActiveWindow() {
    ; update process list
    UpdateProcess()
    
    ; "A" for "Active" window : https://www.autohotkey.com/docs/v2/misc/WinTitle.htm#ActiveWindow
    if not WinExist("A") {
        return
    }
    
    activeWinID := WinGetID("A")
    if (WinGetTitle(activeWinID) != "task_bar_v2.ahk") {
        ; the window is not the task bar,
        ; set the variable for other methods
        global globActiveWinID := WinGetID("A")
    }
    
    ; start the first iteration at the top
    totalRow := LV.GetCount()
    Loop totalRow {
        ; "A_Index" is an automatic variable containing current loop index
        ahkId := LV.GetText(A_Index, 2)
        if (IsNumber(ahkId) and ahkId == globActiveWinID) {
            ;MsgBox("Active : " WinGetProcessName(globActiveWinID))
            ; unselect all row
            LV.Modify(0, "-Select")
            ; select current row
            LV.Modify(A_Index, "+Select")
            ; exit the loop
            break
        }
    }
}
;SetTimer(UpdateActiveWindow, 300)


UpdateProcess(*) {
    ; TODO : maybe usefull later ?
    static IconMap := Map()

    ; Improve performance by disabling redrawing during load.
    LV.Opt("-Redraw")
    
    ; clear remaining items (TODO : optimize this later)
    LV.Delete()
    
    ; Gather a list of running process (source : https://www.autohotkey.com/docs/v2/lib/WinGetList.htm)
    ids := WinGetList(,, "Program Manager")
    for thisId in ids {
        ahkProcess := WinGetProcessName(thisId)
        ahkTitle := WinGetTitle(thisId)
        pid := WinGetPID(thisId)
        exePath := ProcessGetPath(pid)
        
        if (ahkTitle != "" 
            and ahkTitle != "task_bar_v2.ahk"
            and ahkTitle != "Pulse Secure"
            and !InStr(ahkTitle, "JamPostMessage")) {
            ; Ajouter l'icône du processus
            iconIndex := IL_Add(ImageListID1, exePath, 1)
            IL_Add(ImageListID2, exePath, 1)
            
            ahkTitleSmall := SubStr(ahkTitle, 1, 20)
            ; si le titre est trop long, on ajout un marqueur
            if (StrLen(ahkTitle) > 9)
                ahkTitleSmall := ahkTitleSmall . "..."
            
            LV.Add("Icon" . iconIndex, ahkTitleSmall, thisId, ahkProcess)
        }
    }

    ; apply the "Sort" after the list items
    ; any subsequently added rows will appear at the bottom of the list
    LV.ModifyCol(3, "Sort")
    LV.Opt("+Redraw")  ; Re-enable redrawing (it was disabled above).
    ;LV.ModifyCol()  ; Auto-size each column to fit its contents.
    ;LV.ModifyCol(1, 60)  ; Make the Size column at little wider to reveal its header.
}

SwitchView(*) {
    static IconView := false
    if not IconView
        LV.Opt("+Icon")        ; Switch to icon view.
    else
        LV.Opt("+Report")      ; Switch back to details view.
    IconView := not IconView   ; Invert in preparation for next time.
}

; click on item
ActiveWin(LV, RowNumber) {
    ; Get the text of the 2nd field
    ahkId := LV.GetText(RowNumber, 2)
    ;MsgBox("Selected " ahkId " (rownum " RowNumber ")")
    
    ; https://www.autohotkey.com/docs/v2/misc/WinTitle.htm#ahk_id
    if (IsNumber(ahkId) and WinExist(Integer(ahkId))) {
        if (Integer(ahkId) == globActiveWinID) {
            WinMinimize(Integer(ahkId))
            global globActiveWinID := -1
        } else {
            WinActivate(Integer(ahkId))
            global globActiveWinID := Integer(ahkId)
        }
    }
}

; In response to right-click or Apps key
ShowContextMenu(LV, Item, IsRightClick, X, Y) {
    ; Show the menu at the provided coordinates, X and Y.  These should be used
    ; because they provide correct coordinates even if the user pressed the Apps key:
    ContextMenu.Show(X, Y)
}

; Selected "Open" or "Properties" in the context menu
ContextOpenOrProperties(ItemName, *) {
    ; For simplicitly, operate upon only the focused row rather than all selected rows
    FocusedRowNumber := LV.GetNext(0, "F")  ; Find the focused row.
    if not FocusedRowNumber  ; No row is focused.
        return
    FileName := LV.GetText(FocusedRowNumber, 1) ; Get the text of the first field.
    FileDir := LV.GetText(FocusedRowNumber, 2)  ; Get the text of the second field.
    try
    {
        if (ItemName = "Open")  ; User selected "Open" from the context menu.
            Run(FileDir "\" FileName)
        else
            Run("properties " FileDir "\" FileName)
    }
    catch
        MsgBox("Could not perform requested action on " FileDir "\" FileName ".")
}

; Selected "Clear" in the context menu
ContextClearRows(*) {
    RowNumber := 0  ; This causes the first iteration to start the search at the top.
    Loop {
        ; Since deleting a row reduces the RowNumber of all other rows beneath it,
        ; subtract 1 so that the search includes the same row number that was previously
        ; found (in case adjacent rows are selected)
        RowNumber := LV.GetNext(RowNumber - 1)
        if not RowNumber  ; The above returned zero, so there are no more selected rows.
            break
        LV.Delete(RowNumber)  ; Clear the row from the ListView.
    }
}

CheckMouse() {
    global MyGui  ; On récupère la GUI

    ; Récupérer la position de la souris
    MouseGetPos(&MouseX, &MouseY, &WinID)
    
    ; Récupérer la position et taille de la fenêtre
    MyGui.GetPos(&WinX, &WinY, &WinW, &WinH)
    
    ; Vérifier si la souris est sur la fenêtre
    if (WinID = MyGui.Hwnd || MouseY <= 5) {
        MyGui.Show("NoActivate")  ; Affiche sans activer la fenêtre
		UpdateActiveWindow()
    } else {
        MyGui.Hide()  ; Cache la fenêtre si la souris est ailleurs
    }
}
; Lancer la vérification de la souris toutes les 100ms
SetTimer(CheckMouse, 100)

;  left side and the top of the virtual screen (https://www.autohotkey.com/docs/v2/lib/SysGet.htm)
;MsgBox SysGet(76) " x " SysGet(77)

; Expand/Shrink ListView in response to the user's resizing
Gui_Size(thisGui, MinMax, Width, Height) {
    if MinMax = -1  ; The window has been minimized. No action needed.
        return
    ; Otherwise, the window has been resized or maximized. 
    ; Resize the ListView to match ALL the space
    LV.Move(0, 0, Width, Height)
}

CloseApp(*) {
    MyGui.Destroy()
    ExitApp 
}

