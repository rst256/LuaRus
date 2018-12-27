dofile 'interpreters/luabase.lua'
for k,v in pairs(_G) do
	print(k, v)
end
local interpreter = MakeLuaInterpreter(5.3, ' 5.3x')
interpreter.skipcompile = true
return interpreter
