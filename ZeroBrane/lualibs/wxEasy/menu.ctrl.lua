menu = control{
  ctor = function(parent, items) 
		local menuBar = wx.wxMenuBar();
		for k,v in pairs(items) do
			menuBar:Append(wx.wxMenu(v), k);
		end
		parent:SetMenuBar(menuBar);
		return menuBar;
  end,
	methods = {
		new 			= function(ctrl, n, ...) return new(ctrl, n, ...); end
	},
	properties = {
		items = {
			setter = function(ctrl, v) ctrl:SetAutoLayout(v); end,
			getter = function(ctrl) return ctrl:SetAutoLayout(); end
		}
	}
}();


