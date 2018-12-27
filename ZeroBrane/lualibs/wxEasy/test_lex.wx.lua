local overload = require"overload";
local inspect = require("inspect");



local M = {}


local tokenRules = setmetatable({}, {
__newindex=function(t, k, v)
	rawset(t, k, function(mt, ...)
		local self = {}
		v(self, ...)
		return setmetatable(self, t)
	end)
end})

function tokenRules:static(pattern)
	--print( inspect{self,  ...})
			self.pattern = pattern
end


 print( inspect( tokenRules:static("if") )  )