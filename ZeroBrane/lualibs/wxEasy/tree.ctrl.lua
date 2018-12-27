


tree = control{
  ctor = function(parent)
    if parent == nil then error("parent is nil", 2); end
    return wx.wxTreeCtrl(parent, wx.wxID_ANY,
                              wx.wxDefaultPosition, wx.wxSize(-1, 200),
                              wx.wxTR_LINES_AT_ROOT + wx.wxTR_HAS_BUTTONS );
  end,
	events = {
		onEraseBackground = wx.wxEVT_ERASE_BACKGROUND,
		onResize = wx.wxEVT_SIZE,
		onActivate = wx.wxEVT_ACTIVATE,
		onItemCollaps = wx.wxEVT_COMMAND_TREE_ITEM_COLLAPSING,
		onItemExpand = wx.wxEVT_COMMAND_TREE_ITEM_EXPANDING,
		onSelChange = wx.wxEVT_COMMAND_TREE_SEL_CHANGED,
		onItemActivate = wx.wxEVT_COMMAND_TREE_ITEM_ACTIVATED,
		onKeyDown = wx.wxEVT_COMMAND_TREE_KEY_DOWN
	},
	methods = {

		assignImageList = function(ctrl, v) ctrl:AssignImageList(v); end,
		addRoot = function(ctrl, ...) return ctrl:AddRoot(...); end,
		getRoot = function(ctrl) return ctrl:GetRootItem(); end,
		setItemData = function(ctrl, item_id, item_data)
			ctrl:SetItemData(item_id, wx.wxLuaTreeItemData(item_data))
		end,
		getItemData = function(ctrl, item) return ctrl:GetItemData(item) end,
		addItem = function(ctrl, ...) return ctrl:AppendItem(...); end,
		getItemText = function(ctrl, item) print( ctrl:GetItemText(item)); end,
		expand = function(ctrl, ...) ctrl:Expand(...); end,
	},
	properties = {
		items = {
			setter = function(ctrl, v)
				ctrl:Delete(ctrl:GetRootItem());
				if type(v)=='string' then	ctrl:AddRoot(v);
				elseif type(v)=='nil' then
				else ctrl:AddRoot(tostring(v)); end
			end,
			getter = function(ctrl)
				return new(ctrl, "treeItem", ctrl:GetRootItem());
			end
		},
		sel = {

			getter = function(ctrl)
				return new(ctrl, "treeItem", ctrl:GetSelection())
			end
		}
	}
}(visibleCtrl);

treeItem = {
  ctor = function(parent, item_id)
		return {tree=parent, item_id=item_id}
  end,
  methods = {
		AddChild = function(ctrl, ...)
			return new(ctrl.tree, "treeItem",
				ctrl.tree:AppendItem(ctrl.item_id, ...))
		end,
		insert = function(ctrl, ...)
			return new(ctrl.tree, "treeItem",
				ctrl.tree:InsertItem(
					ctrl.tree:GetItemParent(ctrl.item_id),
					ctrl.item_id,...))
		end,
		delete = function(ctrl) ctrl.tree:Delete(ctrl.item_id); end,
		expand = function(ctrl) ctrl.tree:Expand(ctrl.item_id); end
	},
  metamethods = {
		__pairs = function(ctrl)
			local cookie;
			return function(ctrl, key)
				local next_id;
				if key~=nil and cookie~=nil then
					next_id, cookie = ctrl.tree:GetNextChild(ctrl.item_id, cookie);
				else
					next_id, cookie = ctrl.tree:GetFirstChild(ctrl.item_id);
				end
				if next_id:IsOk() then
					local next_item = new(ctrl.tree, "treeItem", next_id);
					return next_item.text, next_item
				end
			end, ctrl
    end,
		__ipairs = function(ctrl)
			local cookie;
			return function(ctrl, key)
				local next_id;
				if key~=nil and cookie~=nil then
					next_id, cookie = ctrl.tree:GetNextChild(ctrl.item_id, cookie);
				else
					next_id, cookie = ctrl.tree:GetFirstChild(ctrl.item_id);
				end
				if next_id:IsOk() then
					local next_item = new(ctrl.tree, "treeItem", next_id);
					return next_id:GetValue(), next_item
				end
			end, ctrl
    end,
		__len = function(ctrl)
			return ctrl.tree:GetChildrenCount(ctrl.item_id, false);
		end
	},
	properties = {
--		items = {
--			setter = function(ctrl, v)
--				ctrl:Delete(ctrl:GetRootItem());
--				if type(v)=='string' then	ctrl:AddRoot(v);
--				elseif type(v)=='nil' then
--				else ctrl:AddRoot(tostring(v)); end
--			end,
--			getter = function(ctrl)
--				return new(ctrl, "treeItem", ctrl.tree:GetRootItem());
--			end
--		},ItemHasChildren
		data = {
			setter = function(ctrl, v)
				ctrl.tree:SetItemData(ctrl.item_id, wx.wxLuaTreeItemData(v));
			end,
			getter = function(ctrl)
				local wx_data = ctrl.tree:GetItemData(ctrl.item_id);
				return wx_data:GetData();
			end
		},
		text = {
			setter = function(ctrl, v) ctrl.tree:SetItemText(ctrl.item_id, v); end,
			getter = function(ctrl) return ctrl.tree:GetItemText(ctrl.item_id); end
		},
		parent = {
			getter = function(ctrl)
				local p_id = ctrl.tree:GetItemParent(ctrl.item_id);
				if p_id:IsOk() then return new(ctrl.tree, "treeItem", p_id); end
			end
		},
		parent = {
			getter = function(ctrl)
				local p_id = ctrl.tree:GetItemParent(ctrl.item_id);
				if p_id:IsOk() then return new(ctrl.tree, "treeItem", p_id); end
			end
		},
		bold = {
			getter = function(ctrl) return ctrl.tree:IsBold(ctrl.item_id) 		end,
			setter = function(ctrl, v) ctrl.tree:SetItemBold(ctrl.item_id, v) end
		},
		font = {
			getter = function(ctrl)
				return ctrl.tree:GetItemFont(ctrl.item_id)
			end,
			setter = function(ctrl, v)
				ctrl.tree:SetItemFont(ctrl.item_id, v)
			end
		},
	}
};