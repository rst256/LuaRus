
local function get_path(file_and_path)
	return file_and_path:match'(.-)[^\\]+$'
end

local base_path = get_path(arg[0])--:match'(.-)[^\\]+$'
if #arg<3 then
	print[[
	Use: tranclate <to> <source-file> <out-file>
	<to>            - destination language (en or ru)
	<source-file>   - file to translate
	<out-file>      - output file
	]]
	os.exit(-1)
end

package.cpath = base_path..'?.dll;'

local mod_transl = require'transl'
mod_transl.basePath = base_path

local o = ''
local u = {}
print(arg[0])
local file_to = io.open(arg[3], 'w+')

mod_transl.transl(arg[2], arg[1], function(s) file_to:write(s) end)


file_to:close()





