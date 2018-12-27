local M = { mt={} }

function M.finite(index_fn, length)
	local new = {}
	return setmetatable(new, {
		__index = index_fn,
		__newindex = error,
		__len = function() return length end,
	})--finite_mt
end

function M.enum(...) --finite
	local new, length = {}, 0
	for k=1, select('#', ...) do
		local e = select(k, ...)
		assert(new[e]==nil)
		new[e] = true
		length = length + 1
	end
	local new_set = M.finite(new, length)
	local new_mt = getmetatable(new_set)
	new_mt.__pairs = function(self) return next, new end
	return new_set
		--M.finite(new, length)--, enum_mt)
end

local e1=M.enum(1,2,3,9)
print(e1[9], e1[5]==nil, #e1)
for k in pairs(e1) do print(k) end