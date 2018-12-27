frame = control{
  ctor = function(parent, style, title)
    local raw_ctrl = wx_raw.wxFrame(parent or wx_raw.NULL,
			style or -1, title or "wxEasy");

		return raw_ctrl;
  end,
  events = {
      onEraseBackground = wx.wxEVT_ERASE_BACKGROUND,
      onResize = wx.wxEVT_SIZE,
      onActivate = wx.wxEVT_ACTIVATE,
      onAuiPanelClose = wxaui.wxEVT_AUI_PANE_CLOSE,
      onClose = wx.wxEVT_CLOSE_WINDOW
    },
    container = true,
    methods = {
      show 			= function(ctrl, v) ctrl:Show(v); 												end,
      new 			= function(ctrl, n, ...) return new(ctrl, n, ...); end
    },
    properties = {
      hide = {
        setter = function(ctrl, v) ctrl:Show(not v); end
      },
      toolTip = {
        setter = function(ctrl, v) ctrl:SetToolTip(v); end,
        getter = function(ctrl) return ctrl:GetToolTip(); end
      },
      autoLayout = {
        setter = function(ctrl, v) ctrl:SetAutoLayout(v); end,
        getter = function(ctrl) return ctrl:SetAutoLayout(); end
      },
--			sizer = {
--        setter = function(ctrl, v) ctrl:SetToolTip(v); end,
--        --getter = function(ctrl) return ctrl:GetToolTip(); end
--      }
    }
};



wxControls.flexSizer = {
  ctor = function(parent, ...)
		local newSizer = wx.wxFlexGridSizer(...);
		parent:SetSizer(newSizer);
		--newSizer:Fit(parent);
		return {sizer=newSizer, parent=parent};
  end,
  container = true,
	methods = {
		add 	= function(ctrl, n, ...)
			local newCtrl = new(ctrl.parent, n, ...);
--			local optionCall = {};
			return maybe.ctor(newCtrl, function(...)
				ctrl.sizer:Add(newCtrl[0], ...);
			end);
--			return setmetatable(optionCall, {
--				__call = function(self, ...)
--					if self==optionCall then
--						ctrl.sizer:Add(newCtrl[0], ...);
--						return newCtrl;
--					else
----						ctrl.sizer:Add(newCtrl[0]);
----						setmetatable(self, {__index=newCtrl});
----						return
--					end
--				end,
--				__index = function(self, key)
--					ctrl.sizer:Add(newCtrl[0]);
--					setmetatable(self, {
--						__index=newCtrl, __newindex=function(t,k,v) newCtrl[k] = v; end
--					});
--					return newCtrl[key];
--				end,
--				__newindex = function(self, key, value)
--					ctrl.sizer:Add(newCtrl[0]);
--					setmetatable(self, {
--						__index=newCtrl, __newindex=function(t,k,v) newCtrl[k] = v; end
--					});
--					newCtrl[key] = value;
--				end
--			});
		end,
		fit 	= function(ctrl)
			ctrl.sizer:Fit(ctrl.parent);
		end,
		minSize 	= function(ctrl, control, ...)
			ctrl.sizer:SetItemMinSize(control[0], ...);
		end,
		maxSize 	= function(ctrl, control, ...)
			ctrl.sizer:SetItemMaxSize(control[0], ...);
		end,
	},
	properties = {
--		visible = {
--			setter = function(ctrl, v)
--				if v then
--					ctrl.sizer.Show(ctrl.sizer, 1);
--				else
--					ctrl.sizer.Hide(ctrl.sizer);
--				end
--			end,
--			getter = function(ctrl) return ctrl.sizer:IsShown(); end,
--		},
		toolTip = {
			setter = function(ctrl, v) ctrl.sizer:SetToolTip(v); end,
			getter = function(ctrl) return ctrl.sizer:GetToolTip(); end
		}
	}
};

wxControls.button = {
  ctor = function(parent, style, title)
		return wx.wxButton(parent, wx.wxID_ANY, title or  "Test Button");
--		wx_raw.wxButton(parent, style or -1, title or "wxEasy");
  end,
  events = {
      onClick = wx.wxEVT_COMMAND_BUTTON_CLICKED
	},
	methods = {
	},
	properties = {
		toolTip = {
			setter = function(ctrl, v) ctrl:SetToolTip(v); end,
			getter = function(ctrl) return ctrl:GetToolTip(); end
		}
	}
};


M.controls = wxControls;

function M.mainLoop(options)
  wx_raw.wxGetApp():MainLoop();
end

return M;