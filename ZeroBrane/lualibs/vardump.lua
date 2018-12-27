local serpent=require'serpent'
local M = {}

local function line(v)
	return serpent.line(v, {sparse=true, maxlevel=5,
			nocode=true, comment=false, compact=true })
end
M.line = line
	
function vardump(...)
	for _, v in ipairs{...} do io.write((line(v):gsub('\t', '\\t'))) end
	io.write'\n'
end

function M.get_call_top(start)
	local k = start or 1
	while debug.getinfo(k, 'l') do k=k+1 end	
	return k-2
end

function Error(message, level)
	error(message, level or M.get_call_top())
end

function lerror(message, level)
	error(message, level or M.get_call_top())
end

return setmetatable(M, { __call=function(self, ...) vardump(...) end } )

