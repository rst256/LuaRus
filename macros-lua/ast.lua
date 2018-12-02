local s = [[
  {"assert", luaB_assert},
  {"collectgarbage", luaB_collectgarbage},
  {"dofile", luaB_dofile},
  {"error", luaB_error},
  {"getmetatable", luaB_getmetatable},
  {"ipairs", luaB_ipairs},
  {"loadfile", luaB_loadfile},
  {"load", luaB_load},
#if defined(LUA_COMPAT_LOADSTRING)
  {"loadstring", luaB_load},
#endif
  {"next", luaB_next},
  {"pairs", luaB_pairs},
  {"pcall", luaB_pcall},
  {"print", luaB_print},
  {"rawequal", luaB_rawequal},
  {"rawlen", luaB_rawlen},
  {"rawget", luaB_rawget},
  {"rawset", luaB_rawset},
  {"select", luaB_select},
  {"setmetatable", luaB_setmetatable},
  {"tonumber", luaB_tonumber},
  {"tostring", luaB_tostring},
  {"type", luaB_type},
  {"xpcall", luaB_xpcall},
  /* placeholders */
  {"_G", NULL},
  {"_VERSION", NULL},

  {"утв", luaB_assert},
  {"собратьмусор", luaB_collectgarbage},
  {"испфайл", luaB_dofile},
  {"ощибка", luaB_error},
  {"взятьметатаблицу", luaB_getmetatable},
  {"ипары", luaB_ipairs},
  {"загрузитьфайл", luaB_loadfile},
  {"загрузить", luaB_load},
#if defined(LUA_COMPAT_LOADSTRING)
  {"загрузитьстроку", luaB_load},
#endif
  {"выбор", luaB_select},
  {"устметатаблицу", luaB_setmetatable},
  {"следующий", luaB_next},
  {"пары", luaB_pairs},
  {"рвызов", luaB_pcall},
  {"печать", luaB_print},
  {"сравнитьнапрямую", luaB_rawequal},
  {"длинанапрямую", luaB_rawlen},
  {"взятьнапрямую", luaB_rawget},
  {"устнапрямую", luaB_rawset},
  {"вчисло", luaB_tonumber},
  {"встроку", luaB_tostring},
  {"тип", luaB_type},
  {"хрвызов", luaB_xpcall},
  {"_ОКР", NULL},
  {"_ВЕРСИЯ", NULL},

]]

getmetatable(s).__index["gmatch_r"] = function(str, ptr, start)
	local ptr_r = ptr:gsub()

end

local dict = {}
for k,v in s:gmatch'%s*{%s*"(.-)"%s*,%s*([%w_]+)%s*}' do
	if dict[v] then
		print(k, dict[v])
	end
	dict[v] = k

--	print(k,v)
end