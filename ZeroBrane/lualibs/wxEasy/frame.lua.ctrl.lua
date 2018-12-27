


frame = control{
  ctor = function(parent, title, style) 
    local raw_ctrl = wx.wxFrame(parent or wx.NULL, --wx.wxID_ANY)
			style or -1, title or "wxEasy");
		return raw_ctrl;
  end,
	methods = {
		new 			= function(ctrl, n, ...) return new(ctrl, n, ...); end,
	},
	properties = {
		autoLayout = {
			setter = function(ctrl, v) ctrl:SetAutoLayout(v); end,
			getter = function(ctrl) return ctrl:SetAutoLayout(); end
		},
		menu = {
			setter = function(ctrl, v) ctrl:SetMenuBar(v); end,
			getter = function(ctrl) return ctrl:GetMenuBar(); end
		},		
	}
}(visibleCtrl);

