-- Copyright 2014 Paul Kulchenko, ZeroBrane LLC; All rights reserved
-- TODO: on select, go to the relevant line
local G = ...
local id = G.ID("REFACTORpanel.referenceview")
local REFACTORpanel = "REFACTORpanel"
local refeditor
local spec = {iscomment = {}}
local TODOTable = {}

local settings
--TODO: hello ()
local function mapTODOS(self,editor,event)
    local text = editor:GetText()
    local i = 0
    local counter = 1
    local tasksListStr = "REFACTORpanel\n"
    tasksListStr = tasksListStr.."\n"
    while true do

        --find next todo index
        i = string.find(text, "fixme:", i+1)
        if i == nil then
            refeditor:SetReadOnly(false)
            refeditor:SetText(tasksListStr)
            refeditor:SetReadOnly(true)
            break
        end
        j = string.find(text, "\n",i+1)
        local taskStr = string.sub(text, i+5,j)
        tasksListStr = tasksListStr..tostring(counter).."."..taskStr

        refeditor:SetReadOnly(false)
        refeditor:SetText(tasksListStr)
        refeditor:SetReadOnly(true)
        counter = counter+1
    end

    --On click of a task, go to relevant position in the text
    refeditor:Connect(wxstc.wxEVT_STC_DOUBLECLICK,
    function(event)
        local line = refeditor:GetCurrentLine()
        local linetx = string.sub(refeditor:GetLine(line), 4)
        i = string.find(editor:GetText(), linetx, 1, true)
        if i then
        editor:GotoPosEnforcePolicy(i-1)
        if not ide:GetEditorWithFocus(editor) then ide:GetDocument(editor):SetActive() end
        end
    end)

end

--local PanelDockedParentList = {
--	project=ide.frame.projnotebook,
--	output=ide:GetOutputNotebook(),
--	none=false
--}

return {
  name = "Refactoring code tools",
  description = "",
  author = "rst256",
  version = 1.0,
  dependencies = 0.81,

  onRegister = function(self)
--    settings = self:GetSettings()
--    settings.PanelDockedParent = (settings.PanelDockedParent or 'output')



local MyPanel1 = wx.wxPanel (ide:GetOutputNotebook(), wx.wxID_ANY, wx.wxDefaultPosition, wx.wxSize( 500,300 ), wx.wxTAB_TRAVERSAL )
local bSizer1 = wx.wxBoxSizer( wx.wxVERTICAL )



    local w, h = 250, 250
    local conf = function(pane)
      pane:Dock():MinSize(w,-1):BestSize(w,-1):FloatingSize(w,h)
    end
--    local layout = ide:GetSetting("/view", "uimgrlayout")
--		for l in layout:gmatch'([^|]+)|' do
--			if layout:match('caption%s*=([^;]+)')=='  Ppp' then print(l) end
--		end


    ide:AddPanelDocked(ide:GetOutputNotebook(), MyPanel1, REFACTORpanel, TR("Refactor"), conf)


  end,

  onUnRegister = function(self)
		self:SetSettings(settings)
--    ide:RemoveMenuItem(id)
  end,

   onEditorFocusSet = function(self, editor, event)
--     mapTODOS(self,editor,event)
   end,

  onEditorCharAdded = function(self, editor, event)
--    mapTODOS(self, editor, event)


	end,



}
