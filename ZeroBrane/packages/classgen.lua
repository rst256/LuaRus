local G = ...
local cs_toolbar_id = G.ID("classgen.toolbar_show_dialog")

local function cs_run()
	local name=ide:GetTextFromUser('Class name?', 'df', 'hgh')
	local editor=ide.GetEditor()
    for line = editor:GetLineCount()-1, 0, -1 do
      local b, e = editor:GetLine(line):match([[^%s*()%-%-.+()]])
      if e then
        editor:DeleteRange(editor:PositionFromLine(line)+b-1, e-b)
      end
    end
end

return {
  name = "Class gen",
  description = "Plugins manager tool",
  author = "rst256",
  version = 0.1,
  dependencies = 1.0,

	onEditorLoad = function(self, editor)
--		editor:SetCodePage(1251)
	end,

	 onEditorNew = function(self, editor)
--		editor:SetCodePage(1251)
	end,

	onRegister = function(self)
		ide:AddTool(TR(self.name), cs_run)
--		ide:GetOutput():SetCodePage(1251)
--		ide:GetOutput():SetFont(ide.font.eNormal)--ide:GetEditor():GetFont())

--			wx.wxFont(ide.config.fontsize or 10, wx.wxFONTFAMILY_MODERN, style,
--    wx.wxFONTWEIGHT_NORMAL, false, ide.config.fontname or "",
--    ide.config.fontencoding or wx.wxFONTENCODING_DEFAULT))

		ide:GetToolBar():AddTool(cs_toolbar_id, TR(self.name),
			wx.wxArtProvider.GetBitmap(wx.wxART_NEW,
			wx.wxART_MENU, ide:GetToolBar():GetToolBitmapSize()),
			TR(self.name)
		)

		ide:GetMainFrame():Connect(cs_toolbar_id,
			wx.wxEVT_COMMAND_MENU_SELECTED, cs_run)

		ide:GetToolBar():Realize()
	end,

  onUnRegister = function(self)
		ide:GetToolBar():DeleteTool(cs_toolbar_id)
    ide:GetToolBar():Realize()
		ide:RemoveTool(TR(self.name))
		ide:GetMainFrame().uimgr:Update()
  end,
}

