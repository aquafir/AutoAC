;AHK PostMessage List: https://www.autohotkey.com/docs/misc/SendMessageList.htm
;Keypresses
global WM_KEYDOWN := 0x0100
global WM_KEYUP := 0x0101
global WM_CHAR := 0x0102
global WM_SYSKEYDOWN := 0x0104 ; https://docs.microsoft.com/en-us/windows/win32/inputdev/wm-syskeydown
;Mouse
global WM_MOUSEHOVER := 0x02A1
global WM_MOUSEMOVE := 0x0200
global WM_LBUTTONDOWN := 0x0201
global WM_LBUTTONUP := 0x0202

global wParam := 0x0000
global wParamDown := 0x0001

MaximizeAll() {
    WinGet, id, List, ahk_exe acclient.exe
    Loop, %id%
    {
        hwnd := id%A_Index%
        ForceFakeFullscreen(hwnd)
    } 
}

ClickAll(x, y, mode := 0) {
    ;Get active AC windows
    WinGet, id, List, ahk_exe acclient.exe
    ;WinGet, id, List, ahk_exe acclient.exe,,aqua
    ;WinGet, OutputVar [, Cmd, WinTitle, WinText, ExcludeTitle, ExcludeText]

    ;Loop through sending a message to each.  
    Loop, %id%
    {
        hwnd := id%A_Index%

        switch mode {
        case 0:
            ClickAC(x,y,hwnd)
        return
        case 1:
            ClickACMove(x,y,hwnd)
            ClickACDown(x, y,hwnd)
        return
        case 2:
            ClickACUp(x, y,hwnd)
        return
        case 3:
            ClickACHover(x,y,hwnd)
        return
        }
    } 
}
ClickAC(x,y,hwnd) {
    ;This approach would be easier but it doesn't move the mouse
    ;ControlClick,, ahk_id %hwnd%,, Left,, x%1889% x%1020%

    ClickACMove(x,y,hwnd)
    ClickACDown(x,y,hwnd)
    ClickACUp(x,y,hwnd)
}

;Set location: https://docs.microsoft.com/en-us/windows/win32/inputdev/wm-mousemove
ClickACMove(x,y,hwnd) {
    lParam := y * 0x10000 + x 
    PostMessage, %WM_MOUSEMOVE%, %wParam%, %lParam%,, ahk_id %hwnd%
}
ClickACHover(x,y,hwnd) {
    lParam := y * 0x10000 + x 
    PostMessage, %WM_MOUSEHOVER%, %wParam%, %lParam%,, ahk_id %hwnd%    
}

ClickACDown(x,y,hwnd) {
    lParam := y * 0x10000 + x 
    ; wParamDown := 0x0001 ;Mouse down
    PostMessage, %WM_LBUTTONDOWN%, %wParamDown%, %lParam%,, ahk_id %hwnd%
}
ClickACUp(x,y,hwnd) {
    lParam := y * 0x10000 + x 
    PostMessage, %WM_LBUTTONUP%, %wParam%, %lParam%,, ahk_id %hwnd%
}

KeyPressAll(key, mode := 0) {
    ;Get active AC windows
    WinGet, id, List, ahk_exe acclient.exe

    ;Loop through sending a message to each.  
    Loop, %id%
    {
        hwnd := id%A_Index%
        switch mode {
        case 0:
            KeyPress(key,hwnd)
        return
    case 1:
        KeyPressDown(key,hwnd)
    return
case 2:
    KeyPressUp(key,hwnd)
return
}
}

}

SendMessageAll(msg) {
    ;Get active AC windows
    WinGet, id, List, ahk_exe acclient.exe
    ;WinGet, id, List, ahk_exe acclient.exe,,aqua
    ;WinGet, OutputVar [, Cmd, WinTitle, WinText, ExcludeTitle, ExcludeText]

    ;Loop through sending a message to each.  
    Loop, %id%
    {
        hwnd := id%A_Index%

        SendMessage(msg, hwnd)
        ; switch mode {
        ; case 0:
        ;     ClickAC(x,y,hwnd)
        ; return
        ; case 1:
        ;     ClickACMove(x,y,hwnd)
        ;     ClickACDown(x, y,hwnd)
        ; return
        ; case 2:
        ;     ClickACUp(x, y,hwnd)
        ; return
        ; case 3:
        ;     ClickACHover(x,y,hwnd)
        ; return
        ; }
    } 
}

SendMessage(msg, hwnd) {
    length := StrLen(msg)
    loop %length% {
        c := SubStr(msg, A_Index, 1)
        KeyPress(c, hwnd)
    }
}

;WM_CHAR: https://docs.microsoft.com/en-us/windows/win32/inputdev/wm-char
KeyPressChar(key, hwnd){
    name := GetKeyName(key)
    vk:=GetKeyVK(key)

    ;Get correct lParams to pass along
    scanCode :=GetKeySC(key)
    lParam := 0x00000001 | (scanCode << 16)

    PostMessage, %WM_CHAR%, %vk%, %lParam%, , ahk_id %hwnd%
}

;https://docs.microsoft.com/en-us/windows/win32/inputdev/wm-keydown
;https://docs.microsoft.com/en-us/windows/win32/inputdev/wm-keyup
KeyPress(key, hwnd){
    ;KeyPressDown(key, hwnd)
    KeyPressChar(key, hwnd)
    ;KeyPressUp(key, hwnd)
}

KeyPressDown(key,hwnd) {
    name := GetKeyName(key)
    vk:=GetKeyVK(key)
    ;sc:=GetKeySC(key)

    ;Get correct lParams to pass along
    repeatCount := 0
    scanCode :=GetKeySC(key)
    extended := 0
    context := 0
    previousState := 0
    transition := 0

    lParamDown := repeatCount
    | (scanCode << 16)
    | (extended << 24)
    | (context << 29)
    | (previousState << 30)
    | (transition << 31)

    PostMessage, 0x100, %vk%, %lParamDown%, , ahk_id %hwnd%
}

KeyPressUp(key,hwnd) {
    name := GetKeyName(key)
    vk:=GetKeyVK(key)
    ;sc:=GetKeySC(key)

    ;Get correct lParams to pass along
    repeatCount := 0
    scanCode :=GetKeySC(key)
    extended := 0
    context := 0
    previousState := 1
    transition := 1

    lParamUp := repeatCount
    | (scanCode << 16)
    | (extended << 24)
    | (context << 29)
    | (previousState << 30)
    | (transition << 31) 

    PostMessage, 0x101, %vk%, %lParamUp%, , ahk_id %hwnd%
}

StartingSettings() {
    to := 100
    Click 1840, 998
    Sleep %to%
    Click 1754, 621
    Sleep %to%
    Click 1630, 859
    Sleep %to%
    Click 1630, 880
    Sleep %to%
    Click 1629, 899
    Sleep %to%
    Click 1908, 905
    Sleep %to%
    Click 1630, 811
    Sleep %to%
    Click 1631, 873
    Sleep %to%
    Click 1631, 893
    Sleep %to%
    Click 1907, 910
    Sleep %to%
    Click 1630, 647
    Sleep %to%
    Click 1664, 953
    Sleep %to%
}
DeleteCharacter(){
    MouseGetPos, ox, oy
    Click 121, 583
    Send DELETE
    Click 319, 401
    MouseMove, %ox%, %oy%,1
}

ForceFakeFullscreen(hwnd := -1)
{
    CoordMode Screen, Window
    static WINDOW_STYLE_UNDECORATED := -0xC40000
    if(hwnd == -1)
        WinGet, id, ID, A
    else
        WinGet, id, ID, ahk_id %hwnd%
    inf := Object()
    if(hwnd == -1)
        WinGet, ltmp, Style, A
    else
        WinGet, ltmp, Style, ahk_id %hwnd%
    inf["style"] := ltmp
    WinGetPos, ltmpX, ltmpY, ltmpWidth, ltmpHeight, ahk_id %id%
    inf["x"] := ltmpX
    inf["y"] := ltmpY
    inf["width"] := ltmpWidth
    inf["height"] := ltmpHeight
    WinSet, Style, %WINDOW_STYLE_UNDECORATED%, ahk_id %id%
    mon := GetMonitorActiveWindow(hwnd)
    SysGet, mon, Monitor, %mon%
    if(hwnd == -1)
        WinMove, A, , %monLeft%, %monTop%, % monRight-monLeft, % monBottom-monTop
    else
        WinMove, ahk_id %id%, , %monLeft%, %monTop%, % monRight-monLeft, % monBottom-monTop
}

GetMonitorAtPos(x, y)
{
    ;; Monitor number at position x, y or -1 if x, y outside monitors.
    SysGet monitorCount, MonitorCount 
    i := 0
    while (i < monitorCount) {
        SysGet area, Monitor, %i%
        if ( areaLeft <= x && x <= areaRight && areaTop <= y && y <= areaBottom ) {
            return i
        }
        i := i+1
    }
return -1
}

GetMonitorActiveWindow(hwnd := -1)
{
    ; Get Monitor number at the center position of the Active window.
    if(hwnd == -1) {
        WinGetPos x, y, width, height, A
        return GetMonitorAtPos(x+width/2, y+height/2)
    }
    else {
        WinGetPos, x, y, width, height, ahk_id %hwnd%
        return GetMonitorAtPos(x+width/2, y+height/2)
    }
}

SendCommand(command = "", finish = true)
{
    to := 100
    oldClip := Clipboard
    Clipboard := command
    Sleep %to%
    Send {enter}
    Sleep %to%
    Send {ctrl down}v{ctrl up}
    if(finish) {
        Sleep %to%
        Send {enter}
    }
    Clipboard := oldClip
}

