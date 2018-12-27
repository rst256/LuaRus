
local function get_path(file_and_path)
	return file_and_path:match'(.-)[^\\]+$'
end

local base_path = get_path(arg[0])--:match'(.-)[^\\]+$'
package.cpath = base_path..'?.dll;'

local mod_transl = require'transl'
mod_transl.basePath = base_path

local o = ''
local u = {}

local file_new_words = io.open(arg[3], 'w+')

mod_transl.transl(arg[2], arg[1], 	
	function(s) 
--		io.write(s) 
	end
	,function(s) 
--		print(s)
		file_new_words:write(s..'\n') 
		return false 
	end
)


file_new_words:close()





