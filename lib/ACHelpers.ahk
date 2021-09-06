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

BorderlessAll() {
    MaximizeAll(1)
}
MaximizeAll(borderlessOnly := 0) {
    CoordMode Screen, Window
    static WINDOW_STYLE_UNDECORATED := -0xC40000

    WinGet, id, List, ahk_exe acclient.exe
    Loop, %id%
    {
        hwnd := id%A_Index%
        WinSet, Style, %WINDOW_STYLE_UNDECORATED%, ahk_id %hwnd%
        if(borderlessOnly)
            continue

        WinMaximize, ahk_id %hwnd%
    } 
}

ClickAll(x, y, mode := 0) {
    ;Get active AC windows
    WinGet, id, List, ahk_exe acclient.exe

    ;Loop through sending a message to each.  
    Loop, %id%
    {
        hwnd := id%A_Index%

        switch mode {
        case 0:
            ClickAC(x,y,hwnd)
        case 1:
            ClickACMove(x,y,hwnd)
            ClickACDown(x, y,hwnd)
        case 2:
            ClickACUp(x, y,hwnd)
        case 3:
            ClickACHover(x,y,hwnd)
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
        case 1:
            KeyPressDown(key,hwnd)
        case 2:
            KeyPressUp(key,hwnd)
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

DeleteCharacter(){
    MouseGetPos, ox, oy
    Click 121, 583
    Send DELETE
    Click 319, 401
    MouseMove, %ox%, %oy%,1
}