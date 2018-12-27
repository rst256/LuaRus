
--package.cpath = ";?.dll;;../../bin/?.dll;./?.so;../lib/?.so;../lib/vc_dll/?.dll;../lib/bcc_dll/?.dll;../lib/mingw_dll/?.dll;"
local wx_raw = require("wx")

local M = {}
local wxControls = {};
local M_mt_stub = {"wxEasy package"};

M.path = [[C:\ZeroBrane\lualibs\wxEasy\]]


local maybe = {}
function maybe.call(fn, ...)
	if type(fn)=='function' then return fn(...) end
end
function maybe.ctor(obj, ctor)
	local optionCall = {};
	local function skip_ctor_fn(...)
		ctor(...);
		setmetatable(optionCall, { --fixme: add another methamethods support
			__index=obj,
			__newindex=function(t,k,v) obj[k] = v; end,
		});
	end

	return setmetatable(optionCall, {
		__call = function(self, ...)
			if self==optionCall then
				skip_ctor_fn(...);
				return obj;
			else
				error('maybe.ctor call on bad self: '..tostring(self), 1);
			end
		end,
		__index = function(self, key)
			skip_ctor_fn();
			return obj[key];
		end,
		__newindex = function(self, key, value)
			skip_ctor_fn();
			obj[key] = value;
		end
	});
end


local mt_fields = '__call;__sub;__add;__unm;__pairs;__ipairs;__len;'
local ctrl_base_env = setmetatable({}, {__index = _G });
local ctrl_member_types = {
	'events', 'metamethods', 'properties', 'methods', 'options'
};

local function loadCtrl(name)
	local preloaded_ctrl = rawget(wxControls, name)
	if preloaded_ctrl then return preloaded_ctrl end
	local filename = M.path..name..'.ctrl.lua'
	local file = io.open(filename, 'r');
	if not file then
		error("Control module file not found "..filename, 1);
	end
	local source = file:read"*a";
	file:close();

	local ctrl_env = setmetatable({}, {
		__index = ctrl_base_env,
		__newindex = function(self, key, val)
--			if type(val)=='number' then
--				wxControls.events[key] = val;
--			elseif type(val)=='function' then
--				--rawset(self, key, val)
--				if key=='ctor' then
--					wxControls.ctor = val;
--				elseif mt_fields:find(key..';') then
--					wxControls.metamethods[key] = val;
--				else
--					wxControls.methods[key] = val;
--				end
--			else
--				wxControls.properties[key] = val;
--			end
			val.class = key;
			wxControls[key] = val;
			rawset(self, key, val);
		end
	})

	if _VERSION <= "Lua 5.1" then
		chunk_fn, errmsg = loadstring(source, filename);
		if chunk_fn then	setfenv(chunk_fn, ctrl_env or _G) end
	else
		chunk_fn, errmsg = load(source, filename, "bt", ctrl_env or _G);
	end
	if not chunk_fn then error(errmsg, 2); end
	chunk_fn();
	--wxControls[name] =
	return wxControls[name];
end

local function new(parent_ctrl, ctrl_class_name, ...)
	local class_name 		= 	ctrl_class_name;
  local ctrl_metadata = 	loadCtrl(class_name);

	if not ctrl_metadata then
--		ctrl_metadata = ;
		--print((ctrl_metadata))
    error('wxEasy error: widget class "'..class_name..'" not defined', 2);
  end

	local events			 	= 	ctrl_metadata.events 			or  {};
	local metamethods 	= 	ctrl_metadata.metamethods or  {};
	local options 			= 	ctrl_metadata.options 		or  {};


  if options.virtual then
    error('wxEasy error: widget class "'..class_name..'" is virtual', 2);
  end
  local ctrl = ctrl_metadata.ctor(parent_ctrl, ...);

	local ctrl_mt ={
    __newindex = function(t, k, v)
			local event = events[k]
      if event ~= nil then
        if type(v) ~= "function" then
          error('set event error: expect function, got '..type(v), 2);
        end
				if type(event) == "number" then
					ctrl:Connect(event, function(event_raw)
						if not v(t, event_raw) then event_raw:Skip(); end
					end);
				elseif type(event) == "function" then
					ctrl:Connect(event(ctrl, t, k, v));
				elseif type(event) == "table" then
					local wrapper = event.wrapper or event_wrapper;
					if type(wrapper)=='function' then
						ctrl:Connect(event.id, function(event_raw)
							if not v(t, wrapper(event_raw)) then event_raw:Skip(); end
						end)
--					elseif type(wrapper)=='table' then
--						ctrl:Connect(event.id, function(event_raw)
--							if not v(t, event_arg) then event_raw:Skip(); end
--						end);
					end
				end
      else
        local property = ctrl_metadata.properties[k];
        if property ~= nil then
          if property.readonly or (not property.setter) then
            error('property "'..k..'" is read only', 2);
          elseif property.overloadable then
            rawset(t, k ,v);
          elseif property.setter then
            property.setter(ctrl, v);
          else
            property.value = v;
          end
        else
--          rawset(t, k ,v);
					error('property "'..k..'" not defined in class '..tostring(t.class), 1);
        end
      end

    end,

  __index = setmetatable({ class=class_name }, { __index=function(t, k)
    if k==nil then -- or k=='0'
      return ctrl;
    end

    local method = ctrl_metadata.methods[k] or false;
    if method then
      return function(...) return method(ctrl, ...); end;
    end

    local property = ctrl_metadata.properties[k];
    if property ~= nil then
      if property.writeonly or (not property.getter) then
        error('wxEasy error: property "'..k..'" is write only', 2);
      elseif property.getter then
        return property.getter(ctrl);
      else
        return property.value;
      end
    end

		local event = events[k];
			if event ~= nil then
				return setmetatable({}, {

				});
			end
		end})
  }

	for k,v in pairs(metamethods) do
		ctrl_mt[k] = function(...) return v(ctrl, ...) end
	end

  return setmetatable({}, ctrl_mt);
end

ctrl_base_env.new = new;

function M.new(class_name, ...)
  return new(false, class_name, ...)
end

function M.control(ctrl_def)
	local ctrl_def = ctrl_def or {};
--	if ctrl_def.inherits == nil then ctrl_def.inherits = {}; end
	return function(...)
		local inherits = {};
		local inh_mbr_types = {};
		for _, v in ipairs{...} do
			table.insert(inherits, v);
			for _, mbr_type in ipairs(ctrl_member_types) do
				if v[mbr_type] and not inh_mbr_types[mbr_type] then
					ctrl_def[mbr_type] = setmetatable(ctrl_def[mbr_type] or {}, {
						__index = function(self, key)
							for k = 1, #inherits do
								local mbrs = inherits[k][mbr_type]
								if mbrs and mbrs[key] then return mbrs[key]; end
							end
						end
					});
					inh_mbr_types[mbr_type] = true;
				end
			end
		end
		ctrl_def.inherits = inherits;
		return ctrl_def;
	end
end
ctrl_base_env.control = M.control;

local function commonProperty(property_name)
	return {
		setter = function(ctrl, v)
			--wx.wxMessageDialog(ctrl, v):ShowModal(true)
			ctrl['Set'..property_name](ctrl, v); 	end,
		getter = function(ctrl) return ctrl['Get'..property_name](ctrl); 	end
	};
end
ctrl_base_env.commonProperty = commonProperty;


ctrl_base_env.visibleCtrl = {
  events = {
		onEraseBackground = wx.wxEVT_ERASE_BACKGROUND,
		onResize = wx.wxEVT_SIZE,
		onActivate = wx.wxEVT_ACTIVATE,
		onAuiPanelClose = wxaui.wxEVT_AUI_PANE_CLOSE,
		onClose = wx.wxEVT_CLOSE_WINDOW
	},
	methods = {
		show 			= function(ctrl, v) ctrl:Show(true); 								end,
		hide 			= function(ctrl, v) ctrl:Show(false); 							end,
		setSize = function(ctrl, ...) ctrl:SetSize(...);							end,
	},
	properties = {
		visible = {
			setter = function(ctrl, v) ctrl:Show(not v); 								end,
			getter = function(ctrl) return ctrl.sizer:IsShown(); 				end
		},
		toolTip = commonProperty"ToolTip",
		name = commonProperty"Name",
		label = commonProperty"Label",
--		{
--			setter = function(ctrl, v) ctrl:SetToolTip(v); 							end,
--			getter = function(ctrl) return ctrl:GetToolTip(); 					end
--		}
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
				ctrl.sizer:Add(newCtrl[nil], ...);
			end);
--			return setmetatable(optionCall, {
--				__call = function(self, ...)
--					if self==optionCall then
--						ctrl.sizer:Add(newCtrl[nil], ...);
--						return newCtrl;
--					else
----						ctrl.sizer:Add(newCtrl[nil]);
----						setmetatable(self, {__index=newCtrl});
----						return
--					end
--				end,
--				__index = function(self, key)
--					ctrl.sizer:Add(newCtrl[nil]);
--					setmetatable(self, {
--						__index=newCtrl, __newindex=function(t,k,v) newCtrl[k] = v; end
--					});
--					return newCtrl[key];
--				end,
--				__newindex = function(self, key, value)
--					ctrl.sizer:Add(newCtrl[nil]);
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
			ctrl.sizer:SetItemMinSize(control[nil], ...);
		end,
		maxSize 	= function(ctrl, control, ...)
			ctrl.sizer:SetItemMaxSize(control[nil], ...);
		end,
	},
	properties = {
		direction = {
			setter = function(ctrl, v)
				ctrl.sizer:SetFlexibleDirection(v)
			end,
			getter = function(ctrl) return ctrl.sizer:GetFlexibleDirection(); end,
		},
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

function M.type(options)
  wx_raw.wxGetApp():MainLoop();
end

M = setmetatable(M, {
	__metatable = M_mt_stub,
	__index = function(_, name)
		--print("__index", self, name)
		return function(parent, ...)
			if type(parent)~='userdata' then parent = false end
			return new(parent, name, ...)
		end
	end
})

return M;