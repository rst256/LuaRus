local G = ...
local cs_toolbar_id = G.ID("arh.toolbar_show_dialog")

local function arh_run()
--	local function togglePanel(event)
--  local panel = panels[ID_VIEWOUTPUT]
--  local pane = uimgr:GetPane(panel)
--  local shown = not pane:IsShown()
--  if not shown then pane:BestSize(pane.window:GetSize()) end
--  pane:Show(shown)
--  uimgr:Update()

	DisplayOutputLn'Srart arhivation process ...'
	local cmd_batch_path=[[C:\Portable\AkelPad\AkelFiles\rarcommit.bat ]]
	ide:ExecuteCommand(cmd_batch_path..ide:GetProject(), ide:GetProject(), function(s) DisplayOutput(s) end)
end

return {
  name = "Arh scripts",
  description = "",
  author = "rst256",
  version = 0.1,
  dependencies = 1.0,

	onRegister = function(self)
		ide:AddTool(TR(self.name), arh_run)

		ide:GetToolBar():AddTool(cs_toolbar_id, TR(self.name),
			wx.wxArtProvider.GetBitmap(wx.wxART_REMOVABLE,
			wx.wxART_MENU, ide:GetToolBar():GetToolBitmapSize()),
			TR(self.name)
		)

		ide:GetMainFrame():Connect(cs_toolbar_id,
			wx.wxEVT_COMMAND_MENU_SELECTED, arh_run)

		ide:GetToolBar():Realize()
	end,

  onUnRegister = function(self)
		ide:GetToolBar():DeleteTool(cs_toolbar_id)
    ide:GetToolBar():Realize()
		ide:RemoveTool(TR(self.name))
		ide:GetMainFrame().uimgr:Update()
  end,
}

