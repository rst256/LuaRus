--[[--
  Use this file to specify **User** preferences.
  Review [examples](+C:\ZeroBraneStudio-wxwidgets31x-upgrade\cfg\user-sample.lua) or check [online documentation](http://studio.zerobrane.com/documentation.html) for details.
--]]--


language = "ru"

showmemoryusage = true

--singleinstance = false
styles = loadfile('cfg/tomorrow.lua')('TomorrowNightBright')
styles.caretlinebg={bg = {72, 52, 52}}
styles.sel={bg = {182, 102, 182}}

stylesoutshell = styles
styles.auxwindow = styles.text
styles.calltip = styles.text

activateoutput = true
--autoanalyzer = false
autorecoverinactivity = 240
debugger.runonstart = true
search.autocomplete = true

debugger.verbose = false
editor.tabwidth = 2
editor.usetabs  = true
editor.usewrap = true
--editor.fontname = 'Anka/Coder Condensed'
--acandtip.nodynwords = false

outline.tabwidth = 2
outline.sort = true
outline.showflat  = true
outline.showmethodindicator  = true
outline.autocomplete = true
editor.foldcompact = true

keymap[ID.BREAKPOINTNEXT]   = "Shift-PgDown"
keymap[ID.BREAKPOINTPREV]   = "Shift-PgUp"
keymap[ID.EXIT]             = "Alt-F4"
keymap[ID.VIEWOUTPUT]       = "F6"
keymap[ID.ABOUT]            = ""
keymap[ID.EDITWATCH]        = ""
keymap[ID.CUT]              = "F1"
keymap[ID.COPY]             = "F2"
keymap[ID.PASTE]            = "F3"
keymap[ID.FIND]        			= "F4"
keymap[ID.RUN]        			= "Shift-F5"
keymap[ID.STARTDEBUG]     	= "F5"
keymap[ID.FINDNEXT]         = "Shift-F4"
keymap[ID.UNDO]             = "Ctrl-Z"
keymap[ID.REDO]             = "Ctrl-Y"
keymap[ID.AUTOCOMPLETE]     = "Ctrl-Space"
keymap[ID.COMMENT]          = "Ctrl-Q"
keymap[ID.FOLD]             = "Ctrl-F12"