-- author: Paul Kulchenko
---------------------------------------------------------
local pp = {
	check=3, mt=3, module=1, ctor=3,
	typename=3, class=2, global=1, fn=3,
	ctype=3
}
local decindent = {
 ['fn'] = true, ['mt'] = true, ['ctor'] = true, ['global'] = true,
  ['class'] = true, ['module'] = true}
local incindent = {
  ['fn'] = true, ['mt'] = true, ['ctor'] = true, ['global'] = true,
  ['class'] = true, ['module'] = true}

local funccall = "([A-Za-z_][A-Za-z0-9_]*)%s*"

if not CMarkSymbols then dofile "spec/cbase.lua" end
return {
  exts = {"lmc"},
  lexer = wxstc.wxSTC_LEX_CPP,
  apitype = "cpp",
  linecomment = "//",
  stylingbits = 5,

  isfncall = function(str)
    return string.find(str, funccall .. "%(")
  end,

   isdecindent = function(str)
    str = str:gsub('%-%-%[=*%[.*%]=*%]',''):gsub('%-%-.*','')
    -- this handles three different cases:
    local term = (str:match("^%s*#%s*(%w+)%s*$")
      or str:match("^%s*#%s*(class)[%s%(]")
      or str:match("^%s*#%s*(module)[%s%(]")
      or str:match("^%s*#%s*(global)%f[%W]")
    )
    -- (1) 'end', 'elseif', 'else', 'until'
    local match = term and decindent[term]
    -- (2) 'end)', 'end}', 'end,', and 'end;'
    if not term then term, match = str:match("^%s*#%s*(mt)%s*([%)%}]*)%s*[,;]?") end
    -- endFoo could be captured as well; filter it out
    if term and str:match("^%s*#%s*(mt)%w") then term = nil end
    -- (3) '},', '};', '),' and ');'
    if not term then match = str:match("^%s*[%)%}]+%s*[,;]?%s*$") end

    return match and 1 or 0, match and term and 1 or 0
  end,
--  isincindent = function(str)
--    -- remove "long" comments and escaped slashes (to process \' and \" below)
--    str = str:gsub('%-%-%[=*%[.-%]=*%]',''):gsub('\\[\\\'"]','')
--    while true do
--      local num, sep = nil, str:match("['\"]")
--      if not sep then break end
--      str, num = str:gsub(sep..".-\\"..sep,sep):gsub(sep..".-"..sep,"")
--      if num == 0 then break end
--    end
--    str = (str
--      :gsub('%[=*%[.-%]=*%]','') -- remove long strings
--      :gsub('%[=*%[.*','') -- remove partial long strings
--      :gsub('%-%-.*','') -- strip comments after strings are processed
--      :gsub("%b()","()") -- remove all function calls
--    )

--    local func = (isfndef(str) or str:match("%W+function%s*%(")) and 1 or 0
--    local term = str:match("^%s*#%s*(%w+)%W*")
--    local terminc = term and incindent[term] and 1 or 0
--    -- fix 'if' not terminated with 'then'
--    -- or 'then' not started with 'if'
--    if (term == 'class' or term == 'module')
--    or (term == 'for') and not str:match("%S%s+do%f[%W]")
--    or (term == 'while') and not str:match("%f[%w]do%f[%W]")
--    or (term == 'token') and not str:match("%f[%w]do%f[%W]")
--    -- if this is a function definition, then don't increment the level
--    or func == 1 then
--      terminc = 0
--    elseif not (term == 'if' or term == 'elseif') and str:match("%f[%w]then%f[%W]")
--    or not (term == 'for') and str:match("%S%s+do%f[%W]")
--    or not (term == 'while') and str:match("%f[%w]do%f[%W]") then
--      terminc = 1
--    end
--    local _, opened = str:gsub("([%{%(])", "%1")
--    local _, closed = str:gsub("([%}%)])", "%1")
--    -- ended should only be used to negate term and func effects
--    local anon = str:match("%W+function%s*%(.+%Wend%W")
--    local ended = (terminc + func > 0) and (str:match("%W+end%s*$") or anon) and 1 or 0

--    return opened - closed + func + terminc - ended
--  end,
  marksymbols = CMarkSymbols,

  lexerstyleconvert = {
    text = {wxstc.wxSTC_C_IDENTIFIER,},

    lexerdef = {wxstc.wxSTC_C_DEFAULT,},
    comment = {wxstc.wxSTC_C_COMMENT,
      wxstc.wxSTC_C_COMMENTLINE,
      wxstc.wxSTC_C_COMMENTDOC,},
    stringtxt = {wxstc.wxSTC_C_STRING,
      wxstc.wxSTC_C_CHARACTER,
      wxstc.wxSTC_C_VERBATIM,},
    stringeol = {wxstc.wxSTC_C_STRINGEOL,},
    preprocessor= {wxstc.wxSTC_C_PREPROCESSOR,},
    operator = {wxstc.wxSTC_C_OPERATOR,},
    number = {wxstc.wxSTC_C_NUMBER,},

    keywords0 = {wxstc.wxSTC_C_WORD,},
    keywords1 = {wxstc.wxSTC_C_WORD2,},
  },

  keywords = {
    [[ alignas alignof and and_eq asm auto bitand bitor break case catch
       class compl const constexpr const_cast continue
       decltype default delete do dynamic_cast else enum explicit export
       extern for friend goto if inline mutable namespace new noexcept not
       not_eq nullptr operator or or_eq private protected public register
       reinterpret_cast return sizeof static static_assert static_cast
       struct switch template this thread_local throw try typedef typeid
       typename union using virtual volatile while xor xor_eq]],
    [[ NULL bool char char16_t char32_t double false float int long
       short signed true unsigned void wchar_t auto break case const continue default do else enum extern for goto if
       register return sizeof static struct switch typedef union volatile while]],
    [[ NULL char double float int long short signed unsigned void]]
  },
}





--[[
// Lexical states for SCLEX_CPP
%define wxSTC_C_DEFAULT
%define wxSTC_C_COMMENT
%define wxSTC_C_COMMENTLINE
%define wxSTC_C_COMMENTDOC
%define wxSTC_C_NUMBER
%define wxSTC_C_WORD
%define wxSTC_C_STRING
%define wxSTC_C_CHARACTER
%define wxSTC_C_UUID
%define wxSTC_C_PREPROCESSOR
%define wxSTC_C_OPERATOR
%define wxSTC_C_IDENTIFIER
%define wxSTC_C_STRINGEOL
%define wxSTC_C_VERBATIM
%define wxSTC_C_REGEX
%define wxSTC_C_COMMENTLINEDOC
%define wxSTC_C_WORD2
%define wxSTC_C_COMMENTDOCKEYWORD
%define wxSTC_C_COMMENTDOCKEYWORDERROR
%define wxSTC_C_GLOBALCLASS
]]
