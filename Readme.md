# AutoCommand

When Asheron's Call is active:

* `Shift+Enter` starts the autocomplete mode
  * Typing will narrow down the list of commands (you can set the minimum letters typed and the max results easily)
  * If there's only one command left hitting `Enter` will send it to chat
  * If there's more than one command select the desired one:
    * `Enter`
    * [menu #]  (e.g., type 3)
    * `Enter`
* `Ctrl+Enter` will append the command you *type* to the list of commands when you `Enter` it.
* `Alt+Enter` is disabled to prevent accidental fullscreening.  Easy to change the hotkeys with 
* `Alt+1` reloads

* `Win+Alt+1` exits the script (or you can do that through the "A" icon in the Toolbar)



## Config

Configuration is done in the `Config.ini` file.



### Settings

* `MinCharacters` is the minimum amount input before matching commands are sought
* `MaxResults` is the max matching commands to be shown
* Set the location of the tooltip with `XPos` and `YPos`, otherwise it will show by the mouse.
* `CommandPath` is the file that keeps that commands the script looks for matches in.
* `UseCommandTemplates=1` prompts you for input for each instance of `TemplateExpression` in a command
  * Ex.  "A $$, a $$, a $$: Panama" would prompt you for input 3 times if `TemplateExpression` was `$$`
* `Period` lets you set how often the menu will be constructed (in ms)



### Filters

* The normal mode matches if the input is a substring of a command.
* Use `UseSplitTerms=1` to separate the input on spaces/tabs and match each term individually
  * Ex. "eq 1" would match "/ub equip 13"
* `UseStringSimilarity` trumps other modes.  It matches based on how close the input is to the command.  
  * The minimum threshold needed to be a match can be set with `MinRatingToMatch`
  * To show the similarity in the tooltip set `IncludeRating=0`
* `UseRegex` trumps a normal search.  It treats the input as a [regular expression](https://www.autohotkey.com/docs/misc/RegEx-QuickRef.htm#Common) when filtering.
  * Set [options](https://www.autohotkey.com/docs/misc/RegEx-QuickRef.htm#Options) with `RegexOptions`
  * Ex. `^.{5,15}$` would match commands that have 5-15 characters between the start and end of a line.  `D` as an option ensures there is an end line.



### Hotkeys

* Set hotkeys for:
  * `Reload` - Reload the script and commands
  * `Exit` - Quits out of the script.  Can also be done through the TrayIcon with an 'A' on it.
  * `EnterCommand` - Starts accepting input to find a command
  * `AddCommand` - Adds whatever you type before the next `Enter` at the end of your commands

* If `ActiveWindows` has a value it will use that comma-separated list for the window that must be active to enter or add a command.
  * | *Title*                | [Matching Behaviour](https://www.autohotkey.com/docs/misc/WinTitle.htm#Matching) |
    | ---------------------- | ------------------------------------------------------------ |
    | [Part of Window title] |                                                              |
    | ahk_class              | [Window Class](https://www.autohotkey.com/docs/misc/WinTitle.htm#ahk_class) |
    | ahk_id                 | [Unique ID/HWND](https://www.autohotkey.com/docs/misc/WinTitle.htm#ahk_id) |
    | ahk_pid                | [Process ID](https://www.autohotkey.com/docs/misc/WinTitle.htm#ahk_pid) |
    | ahk_exe                | [Process Name/Path](https://www.autohotkey.com/docs/misc/WinTitle.htm#ahk_exe) |
    |                        | [Multiple Criteria](https://www.autohotkey.com/docs/misc/WinTitle.htm#multi) |

  * Ex: `ActiveWindows=ahk_exe notepad++.exe,ahk_class Notepad` would only work when Notepad or Notepad++ were active.



## Todo?

* Add hotkeys to set which filter is being used instead

* Multiple hotkeys allowed for any action

* Filter commands by active window

* In-script ability to sort command list/remove duplicates

* Additional common ways of handling selected command without requiring editing of the script

* Input timeout/override?

  





