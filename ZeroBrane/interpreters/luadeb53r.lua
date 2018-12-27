dofile 'interpreters/luabase.lua'
local interpreter = MakeLuaInterpreter('5.3r', ' 5.3r')
interpreter.skipcompile = true
return interpreter
