local pairs = {
  ['('] = ')', ['['] = ']', ['{'] = '}', ['"'] = '"', ["'"] = "'"}
local closing = [[)}]'"]]
local closing1 = '%W'
return {
  name = "Auto-insertion of delimiters",
  description = [[Adds auto-insertion of delimiters (), {}, [], '', and "".]],
  author = "Paul Kulchenko",
  version = 0.2,

  onEditorCharAdded = function(self, editor, event)
    local keycode = event:GetKey()
    if keycode > 255 then return end -- special or unicode characters can be skipped here
    local char = string.char(keycode)
    local curpos = editor:GetCurrentPos()
		local curstyle = editor:GetStyleAt(curpos+1)
		if curstyle==6 or curstyle==7 or curstyle==10 then
			return
		end
    local charAt = string.char(editor:GetCharAt(curpos))
    if closing:find(char, 1, true) and editor:GetCharAt(curpos) == keycode then
      -- if the entered text matches the closing one
      -- and the current symbol is the same, then "eat" the character
      editor:DeleteRange(curpos, 1)
    elseif pairs[char] and charAt:match(closing1) then
      -- if the entered matches opening delimiter, then insert the pair
      editor:InsertText(-1, pairs[char])
    end
  end,
}
