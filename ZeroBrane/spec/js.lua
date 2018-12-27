-- author: Paul Kulchenko
---------------------------------------------------------

local funccall = "([A-Za-z_][A-Za-z0-9_%.]*)%s*"

if not JSMarkSymbols then dofile "spec/jsbase.lua" end

return {
  exts = {"js", "json"},
  lexer = wxstc.wxSTC_LEX_ESCRIPT,
  apitype = "js",
  linecomment = "//",
  stylingbits = 5,

  isfncall = function(str)
    return string.find(str, funccall .. "%(")
  end,

  marksymbols = JSMarkSymbols,

  typeassigns = function(editor)
    local maxlines = 48 -- scan up to this many lines back
    local iscomment = editor.spec.iscomment
    local assigns = {}
    local endline = editor:GetCurrentLine()-1
    local line = math.max(endline-maxlines, 0)

    while (line <= endline) do
      local ls = editor:PositionFromLine(line)
      local tx = editor:GetLine(line) --= string
		for ident in tx:gmatch[[([A-Za-z_][A-Za-z0-9_%.]*)]] do
			assigns[ident] = ident
		end
      line = line+1
    end

    return assigns
  end,

  lexerstyleconvert = {
    text = {wxstc.wxSTC_ESCRIPT_IDENTIFIER,},

    lexerdef = {wxstc.wxSTC_ESCRIPT_DEFAULT,},
    comment = {wxstc.wxSTC_ESCRIPT_COMMENT,
      wxstc.wxSTC_ESCRIPT_COMMENTLINE,
      wxstc.wxSTC_ESCRIPT_COMMENTDOC,},
    stringtxt = {wxstc.wxSTC_ESCRIPT_STRING,
      wxstc.wxSTC_ESCRIPT_CHARACTER},
    stringeol = {wxstc.wxSTC_ESCRIPT_STRINGEOL,},
    preprocessor= {wxstc.wxSTC_ESCRIPT_PREPROCESSOR,},
    operator = {wxstc.wxSTC_ESCRIPT_OPERATOR,},
    number = {wxstc.wxSTC_ESCRIPT_NUMBER,},

    keywords0 = {wxstc.wxSTC_ESCRIPT_WORD,},
    keywords1 = {wxstc.wxSTC_ESCRIPT_WORD2,},
    keywords2 = {wxstc.wxSTC_LUA_WORD3,},
  },

  keywords = {
    [[ var undefined else do return while continue for switch case if break default typeof true false null class new export import prototypeof prototype document.createElement ]],
	[[ window  NaN ]],
	[[ console.log 
		e.stopPropagation e.buttons e.shiftKey e.target e.dataTransfer e.preventDefault e.ctrlKey 
		document.querySelectorAll document.querySelector
	]]
  },
}
