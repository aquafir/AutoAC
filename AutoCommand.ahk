#SingleInstance, force
#Include lib/string-similarity.ahk
#Include lib/ACHelpers.ahk
Menu, Tray, Icon, black.ico, , 1

;RunAsAdmin()   ;Added if ever needed to try to escalate to admin
Initialize()
Return


;What happens after you select a command
ProcessCommand(cmd) {
    global ubbPath, lastCmd := cmd ;Store command

    ;Use UtilityBeltBroadcast if available
    if(ubbPath && FileExist(ubbPath)) {
        cmd := ubbPath . " " . cmd
        Run, %cmd%,,hide
    }
    else {
        ;Store clipboard, pastes to chat, then restores the previous clipboard
        oldClip := Clipboard
        Clipboard := cmd
        Send {enter}
        Sleep 100
        Send {ctrl down}v{ctrl up}
        Sleep 100
        Send {enter}
        Clipboard := oldClip 
    }
}

;Filter on KeyUp (required vs OnChar to include backspace?) 
FilterCommands(hook, char){
	global minLength, x, y
    display := hook.Input . ":" ;Menu of commands

    ;Check if enough has been typed to start narrowing the list
    if(StrLen(hook.Input) >= minLength) 
        GetMenu(hook.Input, display)

    ;Specify location of tooltip
    if(x)
        ToolTip , % display, x, y
    ;Follow cursor
    else
        ToolTip , % display
}

;After finishing filtering choose a command using the menu made during filtering
ChooseCommand(hook){
    global menu

    if(menu.Count() == 1)
        FillTemplateInput(menu[1])

    else if (menu.Count() > 1) {
        Input, selection, L1, {enter}, 1,2,3,4,5,6,7,8,9
        if(selection > 0 && selection <= menu.Count())
            FillTemplateInput(menu[selection])
    }
    ToolTip
}

FillTemplateInput(byref cmd) {
    global templateExpression

    ;Fill in template parameters if enabled/while they exist
    originalCmd := cmd
    while(templateExpression) {
        ToolTip, Templating: %originalcmd%`n%cmd%
        paramStart := InStr(cmd, templateExpression)

        if(paramStart <= 0)
            break
        Input, param,,{Enter}
        cmd := StrReplace(cmd, templateExpression, param,,1)
    }
    ;Process command after optional templating
    ProcessCommand(cmd)
    ToolTip
}

GetMenu(input, byref display){
    global
    menu := Array()

    if(filterMode == 3) {
        results := stringSimilarity.findBestMatch(input, commands)
        for i, e in results.ratings
        {
            ;Check for sufficient results or min rating
            if(i >= maxResults || e.rating <= minRatingToMatch)
                break

            menu.Push(e.Target)
            if(includeRating)
                display := display . "`n" . i . " (" . e.Rating . "): " . e.target
            else
                display := display . "`n" . i . ": " . e.target
        }
    }
    else {
        menuIndex := 0
        for i, e in commands
        {
            ;Stop if max results already hit
            if(menuIndex >= maxResults)
                break

            ;True while command matches input
            match := true

            ;Regex search
            if(filterMode == 2)
                match := RegExMatch(e, regexOptions . ")" . Input) 
            ;Search terms split by whitespace
            else if(useSplitTerms) {
                for j, t in StrSplit(input, ["`n", A_Space, A_Tab]) {
                    if(!InStr(e, t)) {
                        match := false
                        break
                    }
                }
            }
            ;Default search
            else 
                match := InStr(e, input)

            ;Add command if it's a match
            if(match)
            {
                menu.Push(e) ;Store the command
                display := display . "`n" . ++menuIndex . ": " . e
            }
        } 
    }
return menu
}

;Adds a command if it doesn't already exist/have newlines/is too large
AddCommand(cmd) {
    global
    if(StrLen(cmd) < 1 || StrLen(cmd) > 1000)
        return
    else if(InStr(cmd, "`n"))
        return
    else if(HasVal(commands, cmd)) 
        return

    FileAppend, `n%cmd%, %commandPath%
    commands.Push(cmd)
}
;Trimming whitespace version
HasVal(haystack, needle) { 
    for i, e in haystack 
    {
        if(needle == RegExReplace(e, "\s+$")) { ;Had issues with whitespace at the end and Trim wasn't picking it up with my known omission list
            return i
        }
    }
return 0
}

Initialize() {
    global
    ;;Settings
    IniRead, maxResults, Config.ini, Settings, MaxResults, 5
    if(maxResults > 9 || maxResults < 1) {
        MsgBox For now menu results are constrained to 1-9. Setting to 5
            maxResults := 5
    }
    IniRead, minLength, Config.ini, Settings, MinCharacters, 1
    ;Set tooltip position
    x := -1, y := -1
    IniRead, position, Config.ini, Settings, TooltipPosition, -1
    pos := StrSplit(position,",")
    if (pos[1] > 0 && pos[1] < A_ScreenWidth && pos[2] > 0 && pos[2] < A_ScreenHeight) {
        x := Trim(pos[1]), y := Trim(pos[2])
    }
    ;Set/use UBB
    IniRead, ubbPath, Config.ini, Settings, UBBroadcastPath, -1
    
    ;Read in commands
    IniRead, commandPath, Config.ini, Settings, CommandPath, Commands.txt
    FileRead, commandFile, %commandPath%
    commands := StrSplit(commandFile, ["`n"])
    commandFile := "" ;Free memory
    ;Templating
    IniRead, templateExpression, Config.ini, Settings, TemplateExpression, $$

    ;Filters
    IniRead, useSplitTerms, Config.ini, Filters, UseSplitTerms, 0
    IniRead, includeRating, Config.ini, Filters, IncludeRating, 1
    IniRead, minRatingToMatch, Config.ini, Filters, MinRatingToMatch, 0
    IniRead, regexOptions, Config.ini, Filters, RegexOptions, m 
    stringSimilarity := new stringsimilarity()

    ;Input: https://www.autohotkey.com/docs/commands/filterInputHook.htm
    filterInputHook := InputHook("", "{Enter}", "")
    filterInputHook.KeyOpt("{All}", "+N")
    filterInputHook.OnKeyUp := Func("FilterCommands")
    filterInputHook.OnEnd := Func("ChooseCommand")

    RegisterHotkeysAndShortcuts()
}

RegisterHotkeysAndShortcuts(){
    global
    shortcutMap := Object() ;Maps a triggered hotkey to a command
    ;Set up global hotkeys/shortcuts
    CreateHotkeysFromSection("Config.ini", "GlobalHotkeys")
    CreateShortcutsFromSection("Config.ini", "GlobalShortcuts")

    ;Apply active window restrictions to hotkeys/shortcuts that aren't global
    IniRead, activeWindows, Config.ini, Settings, ActiveWindows
    if(StrLen(activeWindows) > 0) {
        windows := StrSplit(activeWindows,",")
        for i, e in windows {
            GroupAdd, ValidWindow, %e%
        }
        Hotkey, IfWinActive, ahk_group ValidWindow
        }

    ;Set up restricted hotkeys/shortcuts
    CreateHotkeysFromSection("Config.ini", "Hotkeys")
    CreateShortcutsFromSection("Config.ini", "Shortcuts")
}
CreateHotkeysFromSection(config, section) {
    IniRead, keys, %config%, %section%
    actionHotkeys := StrSplit(keys, "`n")

    ;MsgBox % "Setting up: " . actionHotkeys.Count() . " hotkeys`n" . keys
    for i, hotkeyLine in actionHotkeys
    {
        kvp := StrSplit(hotkeyLine, "=")
        action := kvp[1]
        hotkeys := kvp[2]
        ;MsgBox % "KVP: " . action . ", " . hotkeys

        keys := StrSplit(hotkeys, ",")
        for j, e in keys 
            if(StrLen(e) > 0)
            Hotkey, %e%, %action%
    } 
}
CreateShortcutsFromSection(config, section) {
    global shortcutMap
    IniRead, keys, %config%, %section%
    shortcuts := StrSplit(keys, "`n")

    ;MsgBox % "Setting up: " . shortcuts.Count() . " shortcuts`n" . keys
    for i, shortcutLine in shortcuts
    {
        kvp := StrSplit(shortcutLine, "=")
        trigger := kvp[1]
        command := kvp[2]
        ;MsgBox % "KVP: " . trigger . ", " . command

        shortcutMap[trigger] := command
        
        Hotkey, %trigger%, HandleShortcut
    } 
}

;;Shortcut
HandleShortcut:
FillTemplateInput(shortcutMap[A_ThisHotkey])
;MsgBox % "Shortcut: " . A_ThisHotkey . "::" . shortcutMap[A_ThisHotkey]
Return

;;Hotkey actions
CommandFilter:
    filterMode := 1
    filterInputHook.Start()
Return
RegexFilter:
    filterMode := 2
    filterInputHook.Start()
Return
StringDistanceFilter:
    filterMode := 3
    filterInputHook.Start()
Return
RepeatCommand:
    if(StrLen(lastCmd) > 0)
        ProcessCommand(lastCmd)
Return
ClearInput:
    filterInputHook.OnEnd := ""
    filterInputHook.Stop()
    filterInputHook.OnEnd := Func("ChooseCommand")
    filterInputHook.Start()
Return
AddCommand:
    ToolTip, Adding typed command upon Enter
    Input, newCommand,V, {Enter}
    AddCommand(newCommand)
Return
AddClipboardAsCommand:
    AddCommand(Clipboard)
Return
SortCommands:
    Sort, commandFile, U
    FileDelete, %commandPath%
    FileAppend, %commandFile%, %commandPath%
Return
MaximizeAll:
    MaximizeAll()
Return
BorderlessAll:
    BorderlessAll()
Return
ClickAll:
    MouseGetPos, mx, my
    ;MsgBox % mx . ", " . my
    ClickAll(mx, my)
Return
Jump:
    KeyPressAll("Space", 1)
Return
ReleaseJump:
    KeyPressAll("Space", 2) 
Return
Reload:
    Reload
Return
Exit:
ExitApp
Return

RunAsAdmin(){
    full_command_line := DllCall("GetCommandLine", "str")

    if not (A_IsAdmin or RegExMatch(full_command_line, " /restart(?!\S)"))
    {
        try
        {
            if A_IsCompiled
                Run *RunAs "%A_ScriptFullPath%" /restart
            else
                Run *RunAs "%A_AhkPath%" /restart "%A_ScriptFullPath%"
        }
        ExitApp
    } 
}

KeyWaitAny(Options:="")
{
    ih := InputHook(Options)
    if !InStr(Options, "V")
        ih.VisibleNonText := false
    ih.KeyOpt("{All}", "E") ; End
    ih.Start()
    ErrorLevel := ih.Wait() ; Store EndReason in ErrorLevel
return ih.EndKey ; Return the key name
}
; KeyWaitCombo(Options:="")
; {
;     ih := InputHook(Options)
;     if !InStr(Options, "V")
;         ih.VisibleNonText := false
;     ih.KeyOpt("{All}", "E") ; End
;     ; Exclude the modifiers
;     ih.KeyOpt("{LCtrl}{RCtrl}{LAlt}{RAlt}{LShift}{RShift}{LWin}{RWin}", "-E")
;     ih.Start()
;     ErrorLevel := ih.Wait() ; Store EndReason in ErrorLevel
; return ih.EndMods . ih.EndKey ; Return a string like <^<+Esc
; }