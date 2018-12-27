local utf8 = require'lua-utf8'
local M = {}

local function no_transl() end


local function va_args(b, e, a1, a2, ...)
	if a2 then return e, { a1, a2, ... } else return e, a1 end
end
local function pattern(p, transl_fn)
	local _pattern = '^'..p
	local _transl_fn = transl_fn or no_transl
	return function(source, idx, dict, warn) 
		local e, m = va_args( utf8.find(source.text, _pattern, idx) )
		if e then return e, _transl_fn(source, m, dict, warn) end
	end
end
M.pattern = pattern


local function word_transl(source, word, dict, warn)
--	if dict[word]==nil then 
--		warn(' word "'..word..'"') 
--		dict[word] = false
--	else
	local wrd, idx = utf8.match(word, '(.-)(%d*)$')
	--print(wrd, idx)
	local t = dict[wrd]
	if t then return t..idx end
--	end
end
local function ident(p)
	return pattern(p, word_transl)
end
M.ident = ident


local function include_transl(source, a, dict, warn)
	local htype, hfile = utf8.match(a[3], '(.)(.-).$')
	if htype=='<' then 
		dict('$/'..hfile) 
	else 
		dict((source.file:match'(.-)[^\\]+$')..hfile) 
	end
	return a[1]..utf8.sub((dict['#include'] or '#include'), 2)..a[2]..a[3]
end
local function include(p)
	return pattern(p, include_transl)
end
M.include = include


local function preproc_transl(source, a, dict, warn)
	local pp = dict['#'..a[2]]
	if pp then 
		pp = utf8.sub(pp, 2) 
	else 
		warn('preprocessor directive "'..a[2]..'" have no translation')
		pp = a[2] 
	end
	return a[1]..pp
end
local function preproc(p)
	return pattern(p, preproc_transl)
end
M.preproc = preproc



return setmetatable(M, { __index=utf8 })