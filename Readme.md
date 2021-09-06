# AutoAC

To start, run either `AutoCommand.ahk` (requires Autohotkey) or the compiled version `AutoCommand.exe`



Commands may be sent directly with a [Shortcut](#Shortcuts) 

When you input the [Hotkey](#Hotkey) of a [Filter](#Filters):

* Typing will narrow down the list of commands
* Hitting `Enter` will either: 
  * Let you select a command from the menu by choosing its number, 1-9
  * Automatically select the last command if only one exists
  * Cancel if the list is empty.
* If there is a `TemplateExpression` and blanks that need to be filled in the selected command supply them by typing before submitting with `Enter`
* `ProcessCommand()` is where the selected command is handled.



## Config

Configuration is done in the `Config.ini` file.



### Settings

* If `UBBroadcastPath` is set to a valid path it will try to use [UtilityBeltBroadcast](https://github.com/aquafir/UtilityBeltBroadcast) to send a command to all connected clients.

  * WIP, will eventually implement tags or something more specific

* `MinCharacters` is the minimum amount input before matching commands are sought

* `MaxResults` is the max matching commands to be shown

* `TooltipPosition` will set the location the tooltip shows at.  If missing or incorrect it will show by the mouse as you type.

* `CommandPath` is the file that keeps that commands the script looks for matches in.

* If `TemplateExpression` isn't blank you'll be prompted to kill in blanks matching it in the selected command

  * Ex.  `A $$, a $$, a $$: Panama` would prompt you for input 3 times if `TemplateExpression` was `$$`

* If `ActiveWindows` has a value, `[Hotkey]` actions will only trigger if the active window matches that comma-separated list

  * | *Title*                | [Matching Behaviour](https://www.autohotkey.com/docs/misc/WinTitle.htm#Matching) |
    | ---------------------- | ------------------------------------------------------------ |
    | [Part of Window title] |                                                              |
    | ahk_class              | [Window Class](https://www.autohotkey.com/docs/misc/WinTitle.htm#ahk_class) |
    | ahk_id                 | [Unique ID/HWND](https://www.autohotkey.com/docs/misc/WinTitle.htm#ahk_id) |
    | ahk_pid                | [Process ID](https://www.autohotkey.com/docs/misc/WinTitle.htm#ahk_pid) |
    | ahk_exe                | [Process Name/Path](https://www.autohotkey.com/docs/misc/WinTitle.htm#ahk_exe) |
    |                        | [Multiple Criteria](https://www.autohotkey.com/docs/misc/WinTitle.htm#multi) |

  * Ex: `ActiveWindows=Aqua1,ahk_class Notepad` would only work when Notepad or a window with `Aqua1` in the title were active.



### Filters

* The normal mode matches if the input is a substring of a command.
* Use `UseSplitTerms=1` to separate the input on spaces/tabs and match each term individually
  * Ex. `eq 1` would match `/ub equip 13`
* Set [options](https://www.autohotkey.com/docs/misc/RegEx-QuickRef.htm#Options) for `RegexFilter` with `RegexOptions`
  * `D` as an option ensures there is an end line
  * `Di` would also make it case-insensitive
* For `StringDistanceFilter` 
  * `IncludeRating=1` displays distance between the input and command in the menu
  * `MinRatingToMatch` sets a minimum acceptable distance to match



### Hotkeys

* Set zero-plus comma-separated hotkeys for anything in the `[Hotkeys]` or `[GlobalHotkeys]` section using the [Autohotkey syntax](https://www.autohotkey.com/docs/Hotkeys.htm#Symbols).
  * Reuse of a hotkey will replace what it was previously assigned to.
  * `[GlobalHotkeys]` work regardless of restrictions on the active window 
  * Ex: `RepeatCommand=#F5,XButton1` would send your last command again with `Win+F5` or the back button on your mouse
* Set hotkeys for:
  * `CommandFilter` - Filters commands by input or each word of the input if `UseSplitTerms=1`
  * `RegexFilter` - Filters by [regular expression](https://www.autohotkey.com/docs/misc/RegEx-QuickRef.htm#Common)
    * Ex. `^.{5,15}$` would match commands that have 5-15 characters between the start and end of a line. 
  * `StringDistanceFilter` - Filters by [string similarity](https://en.wikipedia.org/wiki/S%C3%B8rensen%E2%80%93Dice_coefficient)  (using [Chunjee's library](https://github.com/Chunjee/string-similarity.ahk))
  * `RepeatCommand` - Resends your last selected command, if one exists
  * `ClearInput` - Tries to clear the filter text
  * `SortCommands` - Alphabetically sorts your commands and gets rid of duplicates
  * `AddCommand` - Adds whatever you type before the next `Enter` at the end of your commands if it doesn't already exist
  * `AddClipboardAsCommand` - Adds whatever is in your clipboard to your commands (if under 1k characters, no new lines, and unique)
  * `Reload` - Reload the script and commands
  * `Exit` - Quits out of the script.  Can also be done through the TrayIcon with an 'A' on it



### Shortcuts

* `[Shortcuts]` let you map a [hotkey](https://www.autohotkey.com/docs/Hotkeys.htm#Symbols) to a command directly.
  * Works with `TemplateExpression`
  * Similar to the hotkeys there is a `[GlobalShortcuts]` that won't restrict shortcut by the active window.
  * Ex:  `XButton2=/mt jump` would map the forward mouse button to 



## AC Specific

Some WIP functionality for sending key/mouse input to inactive AC windows is included in `ACHelpers.ahk`



Hotkeys added:

* `MaximizeAll` - Set all AC windows to borderless-fullscreen 
* `BorderlessAll` - Set all AC windows to borderless
* `ClickAll` - Send a click at the current mouse position to all AC windows
* `Jump` - Starts holding space
* `ReleaseJump` - Releases space



## Demo

The demo shows:

* A regular search to narrow in on navs
* A string similarity search (for the typo-prone) with a template parameter to be filled
* Making hotkeys global

https://user-images.githubusercontent.com/83029060/131530234-513e2f3d-c166-4f72-b8fe-3b6f81abf73a.mp4




## Todo?

Feel free to make suggestions!

* Filter commands by active window

* Alternative ways of handling selected command without requiring editing of the script/install AHK

* Improved command syntax.  Allow comments/other command-specific configuration.

* Make `StrSplit` when reading the Ini only split on the correct/first `=`

  
