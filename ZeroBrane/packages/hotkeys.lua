local hotkeys = {
--	[wx.WXK_ADD] =
--	[wx.WXK_ALT] =
--	[wx.WXK_BACK] =
--	[wx.WXK_CANCEL] =
--	[wx.WXK_CAPITAL] =
--	[wx.WXK_CLEAR] =
--	[wx.WXK_CONTROL] =
--	[wx.WXK_DECIMAL] =
--	[wx.WXK_DELETE] =
--	[wx.WXK_DIVIDE] =(
--	[wx.WXK_DOWN] =
--	[wx.WXK_END] =
--	[wx.WXK_ESCAPE] =
--	[wx.WXK_EXECUTE] =
--	[wx.WXK_F1] =
--	[wx.WXK_F2] =
--	[wx.WXK_F3] =
--	[wx.WXK_F] =
--	[wx.WXK_F] =
--	[wx.WXK_F] =
--	[wx.WXK_F] =
--	[wx.WXK_F] =
--	[wx.WXK_F] =
--	[wx.WXK_F] =
--	[wx.WXK_F] =
--	[wx.WXK_F] =
--	[wx.WXK_F] =
--	[wx.WXK_F] =
--	[wx.WXK_F] =
--	[wx.WXK_F] =
--	[wx.WXK_F] =(
--	[wx.WXK_F] =
--	[wx.WXK_F] =
--	[wx.WXK_F] =
--	[wx.WXK_F] =
--	[wx.WXK_F] =
	[wx.WXK_F11] = '(',
	[wx.WXK_F12] = ')',
--	[wx.WXK_HELP] =
--	[wx.WXK_HOME] =
--	[wx.WXK_INSERT] = '#',
	[20322] = '#',
--	[wx.WXK_LBUTTON] =
--	[wx.WXK_LEFT] =
--	[wx.WXK_MBUTTON] =
--	[wx.WXK_MENU] =
--	[wx.WXK_MULTIPLY] =
--	[wx.WXK_NUMLOCK] =
--	[wx.WXK_NUMPAD] =
--	[wx.WXK_NUMPAD] =
--	[wx.WXK_NUMPAD] =
--	[wx.WXK_NUMPAD] =
--	[wx.WXK_NUMPAD] =
--	[wx.WXK_NUMPAD] =
--	[wx.WXK_NUMPAD] =
--	[wx.WXK_NUMPAD] =
--	[wx.WXK_NUMPAD] =
--	[wx.WXK_NUMPAD] =
--	[wx.WXK_NUMPAD_ADD] =
--	[wx.WXK_NUMPAD_BEGIN] =
--	[wx.WXK_NUMPAD_DECIMAL] =
--	[wx.WXK_NUMPAD_DELETE] =
--	[wx.WXK_NUMPAD_DIVIDE] =
--	[wx.WXK_NUMPAD_DOWN] =
--	[wx.WXK_NUMPAD_END] =
--	[wx.WXK_NUMPAD_ENTER] =
--	[wx.WXK_NUMPAD_EQUAL] =
--	[wx.WXK_NUMPAD_F] =
--	[wx.WXK_NUMPAD_F] =
--	[wx.WXK_NUMPAD_F] =
--	[wx.WXK_NUMPAD_F] =
--	[wx.WXK_NUMPAD_HOME] =
--	[wx.WXK_NUMPAD_INSERT] =
--	[wx.WXK_NUMPAD_LEFT] =
--	[wx.WXK_NUMPAD_MULTIPLY] =
--	[wx.WXK_NUMPAD_PAGEDOWN] =
--	[wx.WXK_NUMPAD_PAGEUP] =
--	[wx.WXK_NUMPAD_RIGHT] =
--	[wx.WXK_NUMPAD_SEPARATOR] =
--	[wx.WXK_NUMPAD_SPACE] =
--	[wx.WXK_NUMPAD_SUBTRACT] =
--	[wx.WXK_NUMPAD_TAB] =
--	[wx.WXK_NUMPAD_UP] =
--	[wx.WXK_PAGEDOWN] =
--	[wx.WXK_PAGEUP] =
--	[wx.WXK_PAUSE] =
--	[wx.WXK_PRINT] =
--	[wx.WXK_RAW_CONTROL] =
--	[wx.WXK_RBUTTON] =
--	[wx.WXK_RETURN] =
--	[wx.WXK_RIGHT] =
--	[wx.WXK_SCROLL] =
--	[wx.WXK_SELECT] =
--	[wx.WXK_SEPARATOR] =
--	[wx.WXK_SHIFT] =
--	[wx.WXK_SNAPSHOT] =
--	[wx.WXK_SPACE] =
--	[wx.WXK_START] =
--	[wx.WXK_SUBTRACT] =
--	[wx.WXK_TAB] =
--	[wx.WXK_UP] =
}

return {
  name = "Hotkeys",
  description = [[---]],
  author = "rst56",
  version = 0.1,

  onEditorKeyDown = function(self, editor, event)
		local key = event:GetKeyCode()+10000*event:GetModifiers()
--		local mod = event:GetModifiers()
		local insert_text = hotkeys[key]
		if insert_text then
--			editor:DeleteRange(editor:GetCurrentPos()-1, 1)
			local pos = editor:GetCurrentPos()
			editor:InsertText(pos, insert_text)
--			editor:SetCurrentPos(pos+#insert_text)
--			editor:ClearSelections()
			editor:SetSelection(pos+#insert_text, pos+#insert_text)
		else
			event:Skip()
		end
		--DisplayOutputLn('Hotkeys: '..key..' `'..(insert_text or '')..'`')
  end,
}

