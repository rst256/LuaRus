local chrome_bin = [[C:\Program Files\Google\Chrome\Application\chrome.exe]]

local htmlInterpreter = {
  name = "html(Chrome)",
  description = "Torch machine learning package",
  api = {"html", "js"},
  frun = function(self,wfilename,rundebug)
    -- check if the path is configured
    -- local torch = ide.config.path.torch or findCmd(win and 'th.bat ' or 'th', os.getenv('TORCH_BIN'))
    -- if not torch then return end

    local filepath = wfilename:GetFullPath()
    if rundebug then
		DisplayOutputLn("Debug not supported yet; '"..rundebug.."'.")
      return
    else
      -- if running on Windows and can't open the file, this may mean that
      -- the file path includes unicode characters that need special handling
      local fh = io.open(filepath, "r")
      if fh then fh:close() end
      if win and pcall(require, "winapi")
      and wfilename:FileExists() and not fh then
        winapi.set_encoding(winapi.CP_UTF8)
        filepath = winapi.short_path(filepath)
      end
    end

    local params = ide.config.arg.any or ide.config.arg.html or '--disable-infobars'
    local cmd = ([["%s" %s "%s"]]):format(
      chrome_bin, params, filepath)
    -- CommandLineRun(cmd,wdir,tooutput,nohide,stringcallback,uid,endcallback)

    return wx.wxShell(cmd)
		--CommandLineRun(cmd, self:fworkdir(wfilename), true, true, nil, nil,
--      function() end)
  end,
  hasdebugger = false,
  -- fattachdebug = function(self)  end,
  scratchextloop = true,
  takeparameters = true,
}

return {
  name = "html(Chrome)",
  description = "Run  html use Chrome",
  author = "rsat256",
  version = 0.01,
  dependencies = 1.10,

  onRegister = function(self)
    ide:AddInterpreter("html", htmlInterpreter)
  end,
  onUnRegister = function(self)
    ide:RemoveInterpreter("html")
  end,

  -- onInterpreterLoad = function(self, interpreter)
  --   if interpreter:GetFileName() ~= "torch" then return end
  --   local torch = ide.config.path.torch or findCmd(win and 'th.bat' or 'th', os.getenv('TORCH_BIN'))
  --   if not torch then return end
  --   local uselua = wx.wxDirExists(torch)
  --   local torchroot = uselua and torch or MergeFullPath(GetPathWithSep(torch), "../")
  --   interpreter.env = setEnv(torchroot, true)
  -- end,
  -- onInterpreterClose = function(self, interpreter)
  --   if interpreter:GetFileName() ~= "torch" then return end
  --   if interpreter.env then unsetEnv(interpreter.env) end
  -- end,
}
