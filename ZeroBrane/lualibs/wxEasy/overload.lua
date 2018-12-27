local M = {}
local M_mt = {}



--local inspect = require("inspect");
--local bt = setmetatable({},{
--		__shl=function(...) return '__shl'..inspect{...}; end
--})
--print(bt<<4)
--print(bt<<"99")
--print(99999<<bt)
--x=99999<<bt
--os.exit()



local default_type = "...";

local function swith_type(type_tree, var)
	local t = type(var);
	if t == "table" or t == "userdata" then
		local mt = getmetatable(var);
		if type(mt) == "string" then
			return type_tree[mt] or type_tree[t] or type_tree[default_type] or false;
		else
			return type_tree[t] or type_tree[default_type] or false;
		end
	else
		return type_tree[t] or type_tree[default_type] or false;
	end
end

local function call_func(type_tree, ...)
	local tt_node, call_tt_node = type_tree, type_tree[default_type];
	for _, arg in ipairs({...}) do
		local r = swith_type(tt_node, arg);
		if r == false then
			break;
		else
			tt_node = r;
			if getmetatable(r) and getmetatable(r).__call then call_tt_node = r; end
		end
	end
	return call_tt_node(...);
end

local function add_overload_func(func_table, sign, ovl_func)
	if type(func_table) ~= "table" then
		error("arg #1 expect table got "..type(func_table), 2)
	end
	if type(sign) ~= "string" then
		error("arg #2 expect string got "..type(ovl_func), 2)
	end
	if type(ovl_func) ~= "function" then
		error("arg #3 expect function got "..type(ovl_func), 2)
	end

	local tt_node = func_table
	for w in string.gmatch(sign, "([_%a%.]+)%s*,?") do --"([%a*%.]+)%s*,?"
		local tt_node_next = tt_node[w] or {};
		if tt_node[w] == nil then
			rawset(tt_node, w, tt_node_next);
		end
		tt_node = tt_node_next;
	end

	setmetatable(tt_node, {
			__call = function(self, ...) return ovl_func(...); end
	});

	return func_table
end

local function overload(func, sign, ovl_func)
	local func_table;
	if type(func) == "function" then
		func_table = setmetatable({}, {
			__call = call_func,
			__metatable = "overload",
			__newindex = add_overload_func
		});
		rawset(func_table, default_type, setmetatable({}, {
			__call = function(self, ...) return func(...); end
		}) );
	else
		func_table = func;
	end
	return add_overload_func(func_table, sign, ovl_func);
end

return overload;
