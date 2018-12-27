local function exePath1(self, version)
  local version = tostring(version or ""):gsub('%.','')
  local mainpath = ide:GetRootPath()
  local macExe = mainpath..([[bin/lua.app/Contents/MacOS/lua%s]]):format(version)
  return ide.config.path['lua'..version]
     or (ide.osname == "Windows" and mainpath..([[bin\lua%s.exe]]):format(version))
     or (ide.osname == "Unix" and mainpath..([[bin/linux/%s/lua%s]]):format(ide.osarch, version))
     or (wx.wxFileExists(macExe) and macExe or mainpath..([[bin/lua%s]]):format(version))
end
dofile 'interpreters/luabase.lua'
local interpreter = MakeLuaInterpreter(5.3, ' 5.3')
interpreter.skipcompile = true
interpreter.name = 'xlua'
--return interpreter
local frun_old=interpreter.frun
  interpreter.frun = function(self, v,rundebug)
		local out_file = v:GetFullPath():gsub('%.xlua$', '.gen.lua')
    CommandLineRun(
			exePath1(self, 5.3)..[[ C:\dev\crack\xlua.lua ]]..v:GetFullPath()..
				' '..out_file,
			self:fworkdir(v),
			true,
			false
		)
		frun_old(self, wx.wxFileName(out_file),rundebug)
  end
--local interpreter = {
--  name = "xlua",
--  description = "XLua interpreter",
--  api = {"baselib", "sample"},
--  frun = function(self, v,rundebug)
--		local out_file = v:GetFullPath():gsub('%.xlua$', '.gen.lua')
--    CommandLineRun(
--			exePath1(self, 5.3)..[[ C:\dev\crack\xlua.lua ]]..v:GetFullPath()..
--				' '..out_file,
--			self:fworkdir(v),
--			true,
--			false
--		)
--		interpreter1:frun(wx.wxFileName(out_file),rundebug)
--  end,
--  hasdebugger = true,
--  fattachdebug = function(self) DebuggerAttachDefault() end,
--}

return {
  name = "...",
  description = "...",
  author = "rst256",
  version = 0.1,

  onRegister = function(self)
    -- add interpreter with name "sample"
    ide:AddInterpreter("xlua", interpreter)
  end,

  onUnRegister = function(self)
    -- remove interpreter with name "sample"
    ide:RemoveInterpreter("xlua")
  end,
}

