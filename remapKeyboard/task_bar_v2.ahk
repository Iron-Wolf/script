
; source script from : https://www.autohotkey.com/docs/v2/lib/ListView.htm#ExAdvanced

; Description :
;  - button with a calendar
;  - list view with user's running process
;    - simple clic to bring the process in front
;    - right clic for context menu


; Create a GUI window
MyGui := Gui("+OwnDialogs +Resize +AlwaysOnTop +ToolWindow")
;MyGui.Opt("-Border")

; Create some buttons
Bcalendar := MyGui.Add("Button", "Default", "Calendar")
Bswitch := MyGui.Add("Button", "x+5", "Switch View")

; Create the ListView and its columns via Gui.Add
LV := MyGui.AddListView("xm r5 w2000 sort", ["ahkTitle", "ahkId", "ahkClass"])
; For sorting, indicate that the column is an integer
LV.ModifyCol(2, "Integer")  

; Create an ImageList so that the ListView can display some icons
ImageListID1 := IL_Create(10)
ImageListID2 := IL_Create(10, 10, true)  ; A list of large icons to go with the small ones.

; Attach the ImageLists to the ListView so that it can later display the icons
LV.SetImageList(ImageListID1)
LV.SetImageList(ImageListID2)

; Apply control events
LV.OnEvent("Click", ActiveWin)
LV.OnEvent("ContextMenu", ShowContextMenu)
Bcalendar.OnEvent("Click", UpdateProcess)
Bswitch.OnEvent("Click", SwitchView)
MyGui.OnEvent("Size", Gui_Size)

; Create a popup menu to be used as the context menu
ContextMenu := Menu()
ContextMenu.Add("Open", ContextOpenOrProperties)
ContextMenu.Add("Properties", ContextOpenOrProperties)
ContextMenu.Add("Clear from ListView", ContextClearRows)
ContextMenu.Default := "Open"  ; Make "Open" a bold font to indicate that double-click does the same thing.

; Display the window
MyGui.Show("x0 y-20")
UpdateProcess()


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
        ahkClass := WinGetClass(thisId)
        ahkTitle := WinGetTitle(thisId)
		if(ahkTitle != "") {
			LV.Add("Icon" . A_Index, ahkTitle, thisId, ahkClass)
		}
    }

    LV.Opt("+Redraw")  ; Re-enable redrawing (it was disabled above).
    LV.ModifyCol()  ; Auto-size each column to fit its contents.
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

ActiveWin(LV, RowNumber) {
    ; Get the text of the first field
    ahkId := LV.GetText(RowNumber, 2)
    ;MsgBox("Selected " ahkId " (rownum " RowNumber ")")
    
    ; https://www.autohotkey.com/docs/v2/misc/WinTitle.htm#ahk_id
    if (IsNumber(ahkId)) {
        WinActivate Integer(ahkId)
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

; Expand/Shrink ListView in response to the user's resizing
Gui_Size(thisGui, MinMax, Width, Height) {
    if MinMax = -1  ; The window has been minimized. No action needed.
        return
    ; Otherwise, the window has been resized or maximized. Resize the ListView to match.
    LV.Move(,, Width - 20, Height - 40)
}
