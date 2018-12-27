local path_sep = '\\'
package.cpath = package.cpath..";..\\..\\clibs53\\?.dll;"

local function get_path(file_and_path)
	return file_and_path:match'(.-)[^\\]+$'
end

local utf8 = require'lua-utf8'
local transl_tools = require'transl-tools'

local M = {}

local function fopen(path, mode)
	local file = io.open(path, mode)
	if not file then
		error(' file '..path..' not found')
	end
	return file
end

local dicts = {}

local function load_dict(path, from, to, dict)
	local d = dict or {}
	local i = 1
	local fname_to = path..'.'..to
	local fname_from = path..'.'..from
	local file_to = io.open(fname_to)
	local file_from = io.open(fname_from)

	if not file_to or not file_from then
		print('load_dict: '..path, 'failed')
		return
	end


	while 1 do
		local word_from = file_from:read'*l'
		local word_to = file_to:read'*l'

		if word_from and word_to then
			if rawget(d, word_from) then
				error('dict conflict "'..rawget(d, word_from)..'"->"'..word_from..'"')
			end
			d[word_from] = word_to
			i = i + 1
		else
			if word_from then
				print('WARNING: dict file '..fname_to..' is smaller than '..fname_from)
			elseif word_to then
				print('WARNING: dict file '..fname_from..' is smaller than '..fname_to)
			end
			break
		end
	end

	file_from:close()
	file_to:close()
	return d
end


local keywords = {}

local function gen_dict__index(kwrds, untransl_fn)
	if untransl_fn then
		return function(self, word)
			local kwrd = kwrds[word]
			if kwrd then return kwrd end
			local t = untransl_fn(word)
			if t~=nil then rawset(self, word, t) return t end
		end
	else
		return kwrds
	end
end

local function init_dict(from_skin, to_skin, untransl_fn)
	local dict_name = from_skin..'\n'..to_skin
	local kwrds = keywords[dict_name]
	local	loaded = {}
	if not kwrds then
		kwrds = load_dict(M.basePath..'skins\\', from_skin, to_skin, {})
		if not kwrds then error('keywords not found') end
--		kwrds[true] = from_skin
--		kwrds[false] = to_skin
		keywords[dict_name] = kwrds
	end
	return setmetatable({}, {
		__index=gen_dict__index(kwrds, untransl_fn),
		__call=function(self, path)
			if not loaded[path] then
				if load_dict((path:gsub('^(%$[/\\])', M.basePath..'skins\\')),
					from_skin, to_skin, self) then
					loaded[path] = true
					return true
				end
			end
		end,
	})
end

--local function getSourceMetadata(file_name)

local function load_source(file_name)
	local file = fopen(file_name)
	local src = file:read'*a'

	file:close()
	local _, i, skin, src_file = utf8.find(
		src, '^[ \t]*//##%s*(%a+)[ \t]*([^\n]*)\n')
	if not src_file or utf8.len(src_file)==0 then src_file = file_name end--or utf8.match(src_file, '^%s+$')
	if i then
		return setmetatable({
			text='\n'..utf8.sub(src, i+1),--..'\n',
			skin=skin, file=file_name, src_file=src_file,
		}, { __metatable='source' })
	else
		error('lang not defined for '..file_name)
	end
end
M.loadSource = load_source



local function transl(file_name, to_skin, out_fn, untransl_fn)
	local idx, line, pos = 1, 1, 1

	local localed = 'transl.lua: '..file_name..':'
	local function warn(...)
		io.write(localed..line..':'..pos..': ')
		print('translation for word "'..s..'" not found')
	end
	local function warn_untransl(s)
		io.write(localed..line..': ')
		print('translation for word "'..s..'" not found')
		return false
	end

	local source
	if getmetatable(file_name)=='source' then
		source = file_name
	else
		source = load_source(file_name)
	end
	local dict = init_dict(source.skin, to_skin, untransl_fn or warn_untransl)
	dict(source.src_file)
--	dict(file_name)
	if not source.src_file:find(path_sep) then
		dict(get_path(file_name)..source.src_file)
	end
	local out = out_fn or io.write
	local src = source.text

	local src_len = utf8.len(src)
--	local from_lexemes = require(source.skin)
	local from_lexemes_fn, err_msg = load(
		fopen(M.basePath..source.skin..'.lua'):read'*a',
		source.skin..'.lua', 'bt', transl_tools)
	if not from_lexemes_fn then error(err_msg) end
	local from_lexemes = from_lexemes_fn()


	out('//## ') out(to_skin) out(' \t ') out(source.src_file)

	while idx<=src_len do
		local i, t

		for ti=1, #from_lexemes do
			i, t = from_lexemes[ti](source, idx, dict, warn)
			if i then break end
		end

		if not i then
			warn('unknown token after:\n'..
				string.format('%q', utf8.sub(src, idx-5, idx+30)))
			return
		end

		local s = utf8.sub(src, idx, i)
		local _, l = utf8.gsub(s, '\n', '')

		out( t or s )

		line = line + l
		if l>0 then
			pos = #(utf8.match(s, '.-([^\n]+)$') or ' ')
		else
			pos = pos+(i-idx)+1
		end
		idx = i + 1
	end
end
M.transl = transl

return M




