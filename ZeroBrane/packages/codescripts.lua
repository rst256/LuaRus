local G = ...
local cs_toolbar_id = G.ID("codescripts.toolbar_show_dialog")


local function cs_run()
	local editor=ide.GetEditor()
    for line = editor:GetLineCount()-1, 0, -1 do
      local b, e = editor:GetLine(line):match([[^%s*()%-%-.+()]])
      if e then
        editor:DeleteRange(editor:PositionFromLine(line)+b-1, e-b)
      end
    end
end

return {
  name = "Code scripts",
  description = "Plugins manager tool",
  author = "rst256",
  version = 0.1,
  dependencies = 1.0,



	onRegister = function(self)



	local function __genOrderedIndex( t )
			local orderedIndex = {}
			for key in pairs(t) do
					table.insert( orderedIndex, key )
			end
			table.sort( orderedIndex )
			return orderedIndex
	end

	local function orderedNext(t, state)
			-- Equivalent of the next function, but returns the keys in the alphabetic
			-- order. We use a temporary ordered key table that is stored in the
			-- table being iterated.

			local key = nil
			--print("orderedNext: state = "..tostring(state) )
			if state == nil then
					-- the first time, generate the index
					t.__orderedIndex = __genOrderedIndex( t )
					key = t.__orderedIndex[1]
			else
					-- fetch the next value
					for i = 1,table.getn(t.__orderedIndex) do
							if t.__orderedIndex[i] == state then
									key = t.__orderedIndex[i+1]
							end
					end
			end

			if key then
					return key, t[key]
			end

			-- no more value to return, cleanup
			t.__orderedIndex = nil
			return
	end

	local function orderedPairs(t)
			-- Equivalent of the pairs() function on tables. Allows to iterate
			-- in order
			return orderedNext, t, nil
	end

		local function ls(obj, ptrn, filter)
			filter = filter or (function(s) return s:upper() end)
			local p = filter(ptrn or '.*')
			for k,v in orderedPairs(obj) do--and type(k)=='string'
				if filter(k):find(p) then
--					local tt, vl = type(v)
--					if tt=='function' then
--						local inf, s = debug.getinfo(v), 'function('
--						vl='function('..inf.nparams..(inf.isvararg and ', ...' or
--						s=s..string.rep('_, ', inf.nparams)
--						if inf.isvararg then
--							s=s..'...'
--						elseif inf.nparams>0 then
--							s=s:sub(1, -2)
--						end
--						s=s..') '..inf.what
					DisplayShell(k..'\t'..tostring(v))
				end
			end
		end

		local ls_item_mt = {}
		function ls_item_mt:__call(p)
			return ls(self.this, p)
		end
		function ls_item_mt:__index(name)
			return setmetatable({ this=assert(self.this[name]) }, ls_item_mt)
		end


    ShellSetAlias('ls', setmetatable ({}, {
      __call=function(self, obj, ptrn, filter)
				return ls(obj, ptrn, filter)
      end,
			__index=function(_, name)
				return setmetatable({ this=_G[name] }, ls_item_mt)
			end
    }))



		ide:AddTool(TR(self.name), cs_run)

		ide:GetToolBar():AddTool(cs_toolbar_id, TR(self.name),
			wx.wxArtProvider.GetBitmap(wx.wxART_TIP,
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

