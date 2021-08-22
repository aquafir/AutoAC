#SingleInstance, force
#Include lib/string-similarity.ahk
Menu, Tray, Icon, black.ico, , 1

;RunAsAdmin()   ;Added if ever needed
Initialize()
Return

;What happens after you select a command
ProcessCommand(cmd) {
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

EnterCommand:
   SetTimer, ShowCommands, %period%
   InputHook.Start()
Return

AddCommand:
    ToolTip, Adding typed command upon Enter
    Input, newCommand,V, {Enter}
    ;Todo: Check for duplicates/sort?
    if(StrLen(newCommand) > 0) {
        FileAppend, `n%newCommand%, Commands.txt
        commands := `n%newCommand%
    }
Return

ShowCommands:
    if(InputHook.InProgress) {
        ;Skip if nothing changed
        if(input == InputHook.Input)
            return

        input := InputHook.Input
        display := input . ":" ;Menu of commands

        ;Check if enough has been typed to start narrowing the list
        if(StrLen(input) >= minLength) 
            menu := GetMenu(input, display)

        ;Specify location of tooltip
        if(x >= 0 && y >= y)
            ToolTip , % display, x, y
        ;Follow cursor
        else
            ToolTip , % display
    }
    else {
        ChooseCommand(menu)
        ;Get rid of tooltip
        ToolTip 
    }
Return

ChooseCommand(menu){
    global useCommandTemplates
    ;Freeze the menu
    SetTimer, ShowCommands, Delete

    ;Halt if no commands exist
    if(menu.Count() < 1) 
        return

    cmd := ""
    ;If only one command matches automatically select it
    if(menu.Count() == 1) 
        cmd := menu[1]
    
    ;Otherwise select from menu
    else {
        Input, selection, , "{enter}}"
        if(selection <= menu.Count() && selection > 0)
            cmd := menu[selection]
        else {
            MsgBox Selection out of bounds
            return
        }
    }
    ;Halt on blank command
    if(cmd == "")
        return

    ;Fill in template blanks
    if(useCommandTemplates) 
        GetTemplateInput(cmd)   

    ;If a valid command was selected process it
    ProcessCommand(cmd)
}

GetTemplateInput(byref cmd) {
    global templateExpression
    originalCmd := cmd
    while(true) {
        ToolTip, Templating: %originalcmd%`n%cmd%
        paramStart := InStr(cmd, templateExpression)

        ;Halt if nothing found
        if(paramStart <= 0)
            break
        ;Replace next parameter with input if blanks still exist
        Input, param,,{Enter}
        ;MsgBox % paramStart . ": " . param . "`n" . StrReplace(cmd, templateExpression, param,,1)
        cmd := StrReplace(cmd, templateExpression, param,,1)
    }
    ToolTip
}

GetMenu(input, byref display){
    local menu := Array()

    if(useSS) {
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
            if(useRegex)
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

Initialize() {
    global
    ;Create input reader:  https://www.autohotkey.com/docs/commands/InputHook.htm
    InputHook := InputHook("", "{Enter}", "") 
    ;;Settings
    IniRead, maxResults, Config.ini, Settings, MaxResults, 5
    IniRead, minLength, Config.ini, Settings, MinCharacters, 1
    IniRead, x, Config.ini, Settings, XPos, -1
    IniRead, y, Config.ini, Settings, YPos, -1
    IniRead, period, Config.ini, Settings, Period, 1000
    ;Read in commands
    IniRead, commandPath, Config.ini, Settings, CommandPath, Commands.txt
    FileRead, commandFile, %commandPath%
    commands := StrSplit(commandFile, ["`n"])
    ;Templating
    IniRead, useCommandTemplates, Config.ini, Settings, UseCommandTemplates, 0
    IniRead, templateExpression, Config.ini, Settings, TemplateExpression, $$

    ;;Filters
    IniRead, useSplitTerms, Config.ini, Filters, UseSplitTerms, 0
    ;String similarity
    IniRead, useSS, Config.ini, Filters, UseStringSimilarity, 0
    IniRead, includeRating, Config.ini, Filters, IncludeRating, 1
    IniRead, minRatingToMatch, Config.ini, Filters, MinRatingToMatch, 0
    stringSimilarity := new stringsimilarity()
    ;Regex
    IniRead, useRegex, Config.ini, Filters, UseRegex, 0
    IniRead, regexOptions, Config.ini, Filters, RegexOptions, m    

    ;;Hotkeys
    IniRead, hkReload, Config.ini, Hotkeys, Reload, !1
    IniRead, hkExit, Config.ini, Hotkeys, Exit, #!1
    Hotkey, %hkReload%, Reload
    Hotkey, %hkExit%, Exit
    ;;Check if inputting commands should only happen in certain windows
    IniRead, activeWindows, Config.ini, Hotkeys, ActiveWindows
    if(StrLen(activeWindows) > 0) {
        windows := StrSplit(activeWindows,",")
        for i, e in windows {
            GroupAdd, ValidWindow, %e%
        }
        ;Restrict subsequent hotkeys to that window group
        Hotkey, IfWinActive, ahk_group ValidWindow
    }
    IniRead, hkEnterCommand, Config.ini, Hotkeys, EnterCommand, +Enter
    Hotkey, %hkEnterCommand%, EnterCommand
    IniRead, hkAddCommand, Config.ini, Hotkeys, AddCommand, ^Enter
    Hotkey, %hkAddCommand%, AddCommand
}


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