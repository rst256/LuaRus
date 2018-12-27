

local overload = require"overload";
local inspect = require("inspect");

function test_overload_function(sign, ...)
--	local ret = "(" .. sign .. ")= `";
--	for _, arg in ipairs({...}) do
--		ret = ret .. "\t" .. tostring(arg);
--	end
--	ret = ret .. "`";
--	print(ret); 
	print("(" .. string.format("%30s", sign) .. ")= `", ...); 
	return sign;
end

function overload_function(...)
	return test_overload_function("default", ...);
end

function add_overload_function_v1(sign)
	overload_function = overload(overload_function, sign, function(...) 
		return test_overload_function(sign, ...);
	end)
end

function add_overload_function_v2(sign)
	overload_function[sign] = function(...) 
		return test_overload_function(sign, ...);
	end
end

--FIXME add_overload_function_v2 bug on single type sign
add_overload_function_v1"number" 
add_overload_function_v2"string number"
add_overload_function_v1"string table"
add_overload_function_v1"string table boolean boolean"
add_overload_function_v1"string"
add_overload_function_v2"string ..."
add_overload_function_v2"boolean ..."
add_overload_function_v2"overload boolean ..."
add_overload_function_v2"table boolean ..."


print(inspect(overload_function));

assert("string" == 
	overload_function("string value"))
assert("number" == 
	overload_function(11))
assert("string number" == 
	overload_function("string value 2", 22))
assert("string table" == 
	overload_function("string value 3", {}))
assert("string table" == 
	overload_function("string value 4", {}, 333))
assert("boolean ..." == 
	overload_function(false, "string value 5", {}, 333))
assert("string table boolean boolean" == 
	overload_function("string value 3", {}, false, true))
assert("string table" == 
	overload_function("string value 3", overload_function, true))
assert("default" == 
	overload_function({}, "string value 3", {}, true))
assert("string ..." == 
	overload_function("string value 3", true))
assert("overload boolean ..." == 
	overload_function(overload_function, false, "string value 6", {}, 333))
assert("table boolean ..." == 
	overload_function({}, false, "string value 7", {}, 333))