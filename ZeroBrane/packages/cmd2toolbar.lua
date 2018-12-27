local G = ...
local toolbar_id = G.ID("cmd2toolbar.toolbar_show_dialog")
--local require = require or G.require
local tools_id = {}



--require'std_ext'
--package.cpath = [[C:\ParseAST\?.dll;]]..package.cpath
--package.path = [[C:\ParseAST\?.lua;]]..package.path
--local lexer=require'lexer'

--local src = [[struct AsgNodes{
--	UT_hash_handle hh;
--	AsgNode * node;
--	char ref_count;
--} *nodes;

--struct AsgNodeInfo{
--	int deph;
--	struct AsgNodes * nodes;
--};
--//l;k;lk


--static unsigned nextch(source *src) {
--	#define RETURN(CH, SH) { src->ch=(CH);\
--		if(src->ch=='\n'){ src->pos=1; (src->line)++; }else (src->pos)++;\
--		src->sh=(SH); return src->ch;\
--	}
--	src->s+=src->sh;
--	if (is_eof(src)) RETURN(0, 0);
--	unsigned ch; const char *s=src->s; const char * const e=src->se;
--	printf("some string
--	%s\n", "string");
--	ch = (unsigned char)s[0];
--	if (ch < 0xC0) goto fallback;
--	if (ch < 0xE0) {
--		if (s+1 >= e || (s[1] & 0xC0) != 0x80) goto fallback;
--		RETURN( ((ch   & 0x1F) << 6) | (s[1] & 0x3F), 2 );
--	}
--	if (ch < 0xF0) {
--		if (s+2 >= e || (s[1] & 0xC0) != 0x80 || (s[2] & 0xC0) != 0x80) goto fallback;
--		RETURN( ((ch   & 0x0F) << 12) | ((s[1] & 0x3F)<< 6) | (s[2] & 0x3F), 3 );
--	}
--	{
--		int count = 0; /* to count number of continuation bytes */
--		unsigned res = 0;
--		while ((ch & 0x40) != 0) { /* still have continuation bytes? */
--			int cc = (unsigned char)s[++count];
--			if ((cc & 0xC0) != 0x80) goto fallback; /* invalid byte sequence, fallback */
--			res = (res << 6) | (cc & 0x3F); /* add lower 6 bits from cont. byte */
--			ch <<= 1; /* to test next bit */
--		}
--		if (count > 5) goto fallback; /* invalid byte sequence */
--		res |= ((ch & 0x7F) << (count * 5)); /* add first byte */
--		RETURN( res, count+1 );
--	}

--	fallback: RETURN( ch, 1 );
--	#undef RETURN
--}
--// void print_asg_node(AsgNode * node, int deph){
--666, .5, 6e+9, 0xff --+ ++
--..
--]]


--local lex = lexer.new(src)
--local iter = lex:skip(1)
--for i in iter do
--	local s = iter:str()
----	if i>2 and i&8~=0 then
--		DisplayOutputLn(('%5d. %30s    %-30s'):format(i, s, iter:pos_begin()))
----	end
--end







local function show_output()
	local uimgr = ide:GetUIManager()
	local pane = uimgr:GetPane'bottomnotebook'
	if not pane:IsShown() then
		pane:BestSize(pane.window:GetSize())
		pane:Show()


		uimgr:Update()
	end
end

local function eval(code--[[ @ prime]]  , mt)
--	if code then
	show_output()
	local fn, err = load(code, '', 't', setmetatable({
		print=DisplayOutputLn,
		editor=ide.GetEditor(),
		project=ide:GetProject(),
		input=function(promt, default) return ide:GetTextFromUser(
			promt or 'input value', 'Lua script tool', default or '')
		end,
--		os={},
	}, { __index=_G}) )
	if not fn then
		DisplayOutputLn(err)
	else
		fn()
	end
end

local function lua_exec(code)
	show_output()
	local fn, err = load(code, '', 't', setmetatable({
		print=DisplayOutputLn,
		editor=ide.GetEditor(),
		project=ide:GetProject(),
		input=function(promt, default) return ide:GetTextFromUser(
			promt or 'input value', 'Lua script tool', default or '')
		end,
		W=require 'winapi'
	}, { __index=_G}) )
	if not fn then
		DisplayOutputLn(err)
	else
		fn()
	end
end

local function cmd_exec(cmd_string, work_dir)
	local t = {
		d = function()
			return ide:GetProject()
		end,
		p = function()
			local s=ide:GetProject():match'.-\\([^\\]+)\\$'
--			print(s, ide:GetProject())
				return s
			end,
		f = function()
			return ide:GetDocument()
		end,
		['?'] = function(promt, caption, default)
			return ide:GetTextFromUser(promt or 'input value',
				caption or 'input value', default or '')
		end
	}

  local wdir, is_cancel = work_dir or ide:GetProject(), false
	for cmd in cmd_string:gmatch'([^\n]+)\n?' do
		cmd = cmd:gsub('\\[ \t]+(.)(.-)\\', function(o, a)
			if is_cancel then return end
			local args = {}
			for arg in a:gmatch'([^,]*),?' do
				table.insert(args, arg)
			end
			local p = t[o](table.unpack(args))
			if p then return p else is_cancel=true end
		end)
		if is_cancel then return end
		cmd = cmd:gsub('\\([^ \t])', function(o)
			if is_cancel then return end
			if not t[o] then error(o) end
			local p = t[o]()
			if p then return p else is_cancel=true end
		end)
		if is_cancel then return end
		if not cmd:match'^%s+$' then
			show_output()
			DisplayOutputLn('\nExecute `'..cmd..'`:')
			ide:ExecuteCommand(cmd, work_dir or ide:GetProject(),
				function(s) DisplayOutput(s) end)
		end
	end
end

local function run_tool(tool)
--	if tool.is_script==nil then

--else
	if tool.is_script then
		return function() lua_exec(tool.cmd) end
	else
		return function() cmd_exec(tool.cmd) end
	end
end

local function hide_tool(tools, idx)
	local place = tools[idx].place or 'm'
	if place:find'm' then
		ide:RemoveTool(TR(tools[idx].name))
	end
	if place:find't' then
		ide:GetToolBar():DeleteTool(G.ID("cmd2toolbar."..(tools.name or 'usertool')..idx))
	end

end

local function remove_tool(tools, idx)
	hide_tool(tools, idx)
	table.remove(tools, idx)
end

local function add_tool(tools, idx)
	local tool_id = G.ID("cmd2toolbar."..(tools.name or 'usertool')..idx)
	local place = tools[idx].place or 'm'
	if place:find'm' then
		ide:AddTool(TR(tools[idx].name), run_tool(tools[idx]))
	end
	if place:find't' then
		local icon
		if wx.wxFileExists(tools[idx].icon or '') then
			icon = wx.wxBitmap(tools[idx].icon or '', wx.wxBITMAP_TYPE_ANY )
		else
			icon = wx.wxArtProvider.GetBitmap(wx.wxART_MISSING_IMAGE,
				wx.wxART_MENU, ide:GetToolBar():GetToolBitmapSize())
		end
		ide:GetToolBar():AddTool(tool_id, TR(tools[idx].name),
			icon,	TR(tools[idx].name))
		ide:GetMainFrame():Connect(tool_id,
			wx.wxEVT_COMMAND_MENU_SELECTED, run_tool(tools[idx]))
	end
end

local function rebuild_tools(t)
	for k=1, #t do hide_tool(t, k) end
	for k=1, #t do add_tool(t, k) end
  ide:GetToolBar():Realize()
	ide:GetMainFrame().uimgr:Update()
end

local function show_tools(t)
	for k=1, #t do add_tool(t, k) end
  ide:GetToolBar():Realize()
	ide:GetMainFrame().uimgr:Update()
end

local function makeUI(parent, self)
local UI = {}
local choices = {}
local settings = self:GetSettings()
settings.tools = settings.tools or {}
local tools = settings.tools
for k, v in ipairs(tools) do
	choices[k] = v.name
end


UI.MyFrame1 = wx.wxDialog(parent or wx.NULL, wx.wxID_ANY, TR"Edit tools", wx.wxDefaultPosition, wx.wxSize(600, 400), wx.wxDEFAULT_DIALOG_STYLE +		wx.wxRESIZE_BORDER + wx.wxSTAY_ON_TOP )

	UI.MyFrame1:SetSizeHints( wx.wxDefaultSize, wx.wxDefaultSize )

	UI.bSizer1 = wx.wxBoxSizer( wx.wxHORIZONTAL )

	UI.bSizer4 = wx.wxBoxSizer( wx.wxVERTICAL )

	UI.toolsListChoices = {}
	UI.toolsList = wx.wxListBox( UI.MyFrame1, wx.wxID_ANY, wx.wxDefaultPosition, wx.wxDefaultSize, choices, 0 )
	UI.bSizer4:Add( UI.toolsList, 5, wx.wxALL + wx.wxEXPAND, 5 )

	UI.bSizer5 = wx.wxBoxSizer( wx.wxHORIZONTAL )

	UI.newTool = wx.wxButton( UI.MyFrame1, wx.wxID_ANY, TR"Add new", wx.wxDefaultPosition, wx.wxDefaultSize, 0 )
	UI.bSizer5:Add( UI.newTool, 0, wx.wxALL, 5 )

	UI.removeTool = wx.wxButton( UI.MyFrame1, wx.wxID_ANY, TR"Remove", wx.wxDefaultPosition, wx.wxDefaultSize, 0 )
	UI.bSizer5:Add( UI.removeTool, 0, wx.wxALL, 5 )

	UI.save = wx.wxButton( UI.MyFrame1, wx.wxID_ANY, TR"Ok", wx.wxDefaultPosition, wx.wxDefaultSize, 0 )
	UI.bSizer5:Add( UI.save, 0, wx.wxALL, 5 )

	UI.cancel = wx.wxButton( UI.MyFrame1, wx.wxID_ANY, TR"Cancel", wx.wxDefaultPosition, wx.wxDefaultSize, 0 )
	UI.bSizer5:Add( UI.cancel, 0, wx.wxALL, 5 )

	UI.bSizer4:Add( UI.bSizer5, 0, wx.wxEXPAND, 5 )


	UI.bSizer1:Add( UI.bSizer4, 0, wx.wxEXPAND, 5 )

	UI.bSizer3 = wx.wxBoxSizer( wx.wxVERTICAL )

	UI.fgSizer1 = wx.wxFlexGridSizer( 6, 2, 0, 0 )
	UI.fgSizer1:AddGrowableRow( 2 )
	UI.fgSizer1:SetFlexibleDirection( wx.wxBOTH )
	UI.fgSizer1:SetNonFlexibleGrowMode( wx.wxFLEX_GROWMODE_SPECIFIED )

	UI.m_staticText2 = wx.wxStaticText( UI.MyFrame1, wx.wxID_ANY, TR"Name", wx.wxDefaultPosition, wx.wxDefaultSize, 0 )
	UI.m_staticText2:Wrap( -1 )
	UI.fgSizer1:Add( UI.m_staticText2, 0, wx.wxALIGN_CENTER_VERTICAL + wx.wxALL, 5 )

	UI.toolName = wx.wxTextCtrl( UI.MyFrame1, wx.wxID_ANY, "", wx.wxDefaultPosition, wx.wxDefaultSize, 0 )
	UI.fgSizer1:Add( UI.toolName, 2, wx.wxALL + wx.wxEXPAND, 5 )



	UI.m_staticText1 = wx.wxStaticText( UI.MyFrame1, wx.wxID_ANY, TR"Icon", wx.wxDefaultPosition, wx.wxDefaultSize, 0 )
	UI.m_staticText1:Wrap( -1 )
	UI.fgSizer1:Add( UI.m_staticText1, 1, wx.wxALIGN_CENTER_VERTICAL + wx.wxALL, 5 )

	UI.toolIcon = wx.wxFilePickerCtrl( UI.MyFrame1, wx.wxID_ANY, "", "Select a file for icon", "*.ico; *.bmp; *.jpg", wx.wxDefaultPosition, wx.wxDefaultSize, wx.wxFLP_DEFAULT_STYLE )
	UI.fgSizer1:Add( UI.toolIcon, 0, wx.wxALL + wx.wxEXPAND, 5 )



--	UI.toolTypeShell = wx.wxRadioButton( UI.MyFrame1, wx.wxID_ANY, "ShellComands", wx.wxDefaultPosition, wx.wxDefaultSize, wx.wxRB_GROUP )
--	UI.fgSizer1:Add( UI.toolTypeShell, 0, wx.wxALL, 5 )

--	UI.toolTypeLua = wx.wxRadioButton( UI.MyFrame1, wx.wxID_ANY, "Lua script", wx.wxDefaultPosition, wx.wxDefaultSize, wx.wxRB_GROUP )
--	UI.fgSizer1:Add( UI.toolTypeLua, 0, wx.wxALL, 5 )
--local _W = {}
--function _W.CheckBox(self, title, pos, ...)
--	local this = {}

	UI.showInToolbar = wx.wxCheckBox( UI.MyFrame1, wx.wxID_ANY, "Show in toolbar", wx.wxDefaultPosition, wx.wxDefaultSize, 0 )
	UI.fgSizer1:Add( UI.showInToolbar, 0, wx.wxALL, 5 )



	UI.showInMenu = wx.wxCheckBox( UI.MyFrame1, wx.wxID_ANY, "Show in tools menu", wx.wxDefaultPosition, wx.wxDefaultSize, 0 )
	UI.fgSizer1:Add( UI.showInMenu, 0, wx.wxALL, 5 )

	UI.isScript = wx.wxCheckBox( UI.MyFrame1, wx.wxID_ANY, "Script", wx.wxDefaultPosition, wx.wxDefaultSize, 0 )
	UI.fgSizer1:Add( UI.isScript, 0, wx.wxALL, 5 )





	UI.m_staticText4 = wx.wxStaticText( UI.MyFrame1, wx.wxID_ANY, TR"Command", wx.wxDefaultPosition, wx.wxDefaultSize, 0 )
	UI.m_staticText4:Wrap( -1 )
	UI.fgSizer1:Add( UI.m_staticText4, 0, wx.wxALL, 5 )


	UI.bSizer3:Add( UI.fgSizer1, 1, wx.wxEXPAND, 5 )



	UI.toolCommand = wx.wxTextCtrl( UI.MyFrame1, wx.wxID_ANY, "", wx.wxDefaultPosition, wx.wxDefaultSize, wx.wxTE_MULTILINE + wx.wxTE_WORDWRAP )
	UI.bSizer3:Add( UI.toolCommand, 2, wx.wxALL + wx.wxEXPAND, 5 )



	UI.m_staticText5 = wx.wxStaticText( UI.MyFrame1, wx.wxID_ANY, TR"", wx.wxDefaultPosition, wx.wxDefaultSize, 0 )
	UI.m_staticText5:Wrap( -1 )
	UI.bSizer3:Add( UI.m_staticText5, 0, wx.wxALL, 5 )


	UI.bSizer1:Add( UI.bSizer3, 5, wx.wxEXPAND, 5 )

--music f(env) = {
--	zki = 'shanson',
--	intel = 'classic',
--	...
--}

	UI.MyFrame1:SetSizer( UI.bSizer1 )
	UI.MyFrame1:Layout()

	UI.MyFrame1:Centre( wx.wxBOTH )

	-- Connect Events

UI.toolsList:Connect( wx.wxEVT_COMMAND_LISTBOX_SELECTED, function(event)
	local tool = tools[UI.toolsList:GetSelection()+1]
	UI.toolName:SetValue(tool.name)
	UI.toolCommand:SetValue(tool.cmd or '')
	UI.toolIcon:SetPath(tool.icon or '')
--	UI.toolTypeLua:SetValue( tool.is_script or false )
--	UI.toolTypeShell:SetValue( not(tool.is_script or false) )
	UI.showInMenu:SetValue( (tool.place or 'm'):find'm' )
	UI.showInToolbar:SetValue( (tool.place or 'm'):find't' )
	UI.isScript:SetValue( tool.is_script )
	event:Skip()
end )

UI.toolsList:Connect( wx.wxEVT_COMMAND_LISTBOX_DOUBLECLICKED, function(event)
	local tool_idx = UI.toolsList:GetSelection()+1
	run_tool(tools[tool_idx])()
	event:Skip()
end )

UI.newTool:Connect( wx.wxEVT_COMMAND_BUTTON_CLICKED, function(event)
	UI.toolsList:InsertItems({'new item'}, UI.toolsList:GetCount())
	table.insert(tools, { name='new item', cmd='', icon='', place='m' })
	event:Skip()
end )



UI.removeTool:Connect( wx.wxEVT_COMMAND_BUTTON_CLICKED, function(event)
	local tool_idx = UI.toolsList:GetSelection()+1
	UI.toolsList:Delete(tool_idx-1)
	remove_tool(tools, tool_idx)
	event:Skip()
end )

UI.save:Connect( wx.wxEVT_COMMAND_BUTTON_CLICKED, function(event)
	self:SetSettings(settings)
--	for k, id in ipairs(tools) do
--		ide:GetToolBar():DeleteTool(G.ID("cmd2toolbar.usertool"..k))
--	end
--	for k=1, #tools do add_tool(tools, k) end
----	for k, v in ipairs(tools) do
----		ide:GetToolBar():AddTool(G.ID("cmd2toolbar.usertool"..k),
----			TR(v.name),
----			wx.wxBitmap(v.icon or '', wx.wxBITMAP_TYPE_ANY ),
----			TR(v.name)
----		)
----		ide:GetMainFrame():Connect(G.ID("cmd2toolbar.usertool"..k),
----			wx.wxEVT_COMMAND_MENU_SELECTED, run_tool(v))
----	end
--  ide:GetToolBar():Realize()
--	ide:GetMainFrame().uimgr:Update()
	rebuild_tools(tools)
	UI.MyFrame1:Hide()
	event:Skip()
end )

UI.cancel:Connect( wx.wxEVT_COMMAND_BUTTON_CLICKED, function(event)
	UI.MyFrame1:Hide()
	event:Skip()
end )

UI.toolName:Connect( wx.wxEVT_COMMAND_TEXT_UPDATED, function(event)
	local tool_idx = UI.toolsList:GetSelection()+1
	UI.toolsList:SetString(tool_idx-1, UI.toolName:GetValue())
	tools[tool_idx].name = UI.toolName:GetValue()
	event:Skip()
end )

UI.toolIcon:Connect( wx.wxEVT_COMMAND_FILEPICKER_CHANGED, function(e)
	local tool_idx = UI.toolsList:GetSelection()+1
	tools[tool_idx].icon = UI.toolIcon:GetPath()
	e:Skip()
end )

--UI.toolTypeShell:Connect( wx.wxEVT_COMMAND_RADIOBUTTON_SELECTED, function(event)
--	local tool_idx = UI.toolsList:GetSelection()+1
--	tools[tool_idx].is_script = false
--	event:Skip()
--end )

--UI.toolTypeLua:Connect( wx.wxEVT_COMMAND_RADIOBUTTON_SELECTED, function(event)
--	local tool_idx = UI.toolsList:GetSelection()+1
--	tools[tool_idx].is_script = true
--	event:Skip()
--end )

UI.toolCommand:Connect( wx.wxEVT_COMMAND_TEXT_UPDATED, function(event)
	local tool_idx = UI.toolsList:GetSelection()+1
	tools[tool_idx].cmd = UI.toolCommand:GetValue()
	event:Skip()
end )

UI.showInToolbar:Connect( wx.wxEVT_COMMAND_CHECKBOX_CLICKED, function(event)
	local tool_idx = UI.toolsList:GetSelection()+1
--	tools[tool_idx].showInToolbar = UI.showInToolbar:GetValue()
	local place = ''
	if UI.showInToolbar:GetValue() then place=place..'t' end
	if UI.showInMenu:GetValue() then place=place..'m' end
	tools[tool_idx].place=place
	event:Skip()
end )

UI.showInMenu:Connect( wx.wxEVT_COMMAND_CHECKBOX_CLICKED, function(event)
	local tool_idx = UI.toolsList:GetSelection()+1
--	tools[tool_idx].showInMenu = UI.showInMenu:GetValue()
	local place = ''
	if UI.showInToolbar:GetValue() then place=place..'t' end
	if UI.showInMenu:GetValue() then place=place..'m' end
	tools[tool_idx].place=place
	event:Skip()
end )

UI.isScript:Connect( wx.wxEVT_COMMAND_CHECKBOX_CLICKED, function(event)
	local tool_idx = UI.toolsList:GetSelection()+1
	if not tools[tool_idx] then return end
	tools[tool_idx].is_script=UI.isScript:GetValue()
	event:Skip()
end )

--UI.MyFrame1:Connect( wx.wxEVT_CLOSE_WINDOW, function(event)

--end )

	function UI:Show(state)	return self.MyDialog1:Show(state)	end
	function UI:IsShown()	return self.MyDialog1:IsShown()	end

	UI.MyFrame1:Show()
	return UI
end

local project_tools = { name='project_tools' }
local _frun

local preproc_file_types = { pp=true }
local preproc_cmds = {}

--function preproc_cmds:define(l)
--	local name, value = l:match'([%w_]+)%s*(.*)'
--DisplayOutputLn(name..', '..value)
--self.defines[name] = value
--end

function preproc_cmds:define(l)
	local name, args = l:match'([%w_]+)%s*(.*)'
--	DisplayOutputLn(name..', '..args)
	self.defines[name] = args
	local s, ss = 'return function '..args..'\n', '--@define '..name..args..'\n'
	for ll in self.lines do
		ss = ss .. '--' .. ll .. '\n'
		if ll:find'^%s*@%s*end' then break end
		s = s .. ll .. '\n'
	end
	s = s .. 'end\n'
	local f = assert(load(s, name, 't', G))()
	preproc_cmds[name] = f
	return ss
end

local strlit_pairs = {
  ['"'] = '"', ["'"] = "'", ["[["] = "]]"
}
local ptrn_macro = '^%s*@%s*([%w_]+)%s*(.*)'
local function preproc_file(srcfile, outfile)
	local out = assert(io.open(outfile, 'w'))
	local _lines=assert(io.open(srcfile)):lines()
	local ctx = {
		defines={},
		line=0,
		source=srcfile,
	}
	function ctx.lines(...)
		ctx.line = ctx.line + 1
		return _lines(...)
	end
	local is_strlit
	for l in ctx.lines do

		local macro, opts = l:match(ptrn_macro)
		if  not is_strlit and macro then

			out:write(preproc_cmds[macro](ctx, opts) or '', '\n')
		else
			for li, ll in l:gmatch'([%[%]])%1()' do

				if is_strlit and li==']' then
					is_strlit = nil
					DisplayOutputLn(ctx.source..':'..ctx.line..': '..li..', '..ll)
				elseif not is_strlit and li=='[' then
					is_strlit = ctx.line
				end
			end
			out:write(l, '\n')
		end
	end
	out:close()
end

local function _onInterpreterLoad(_, interpreter)
	local _frun = interpreter.frun
	interpreter.frun = function(this, wfilename, rundebug)

		local outfile, ext = wfilename:GetFullPath()
			:match'^(.-)%.(.-)%..+$'
		if ext and preproc_file_types[ext] then
			outfile = outfile..'.'..wfilename:GetExt()
			local src_t, out_t =
				wx.wxFileModificationTime(wfilename:GetFullPath()):GetTicks(),
				wx.wxFileModificationTime(outfile):GetTicks()
			if src_t>out_t then
				DisplayOutputLn('PreProcessing file: `'..
					wfilename:GetFullPath()..'`')
				preproc_file(wfilename:GetFullPath(), outfile)
			end
--			DisplayOutputLn(wx.wxFileModificationTime(wfilename:GetFullPath()):GetTicks()..', '..wfilename:GetExt())
--			DisplayOutputLn(outfile)
			return _frun(this, wx.wxFileName(outfile), rundebug)
		end
		return _frun(this, wfilename, rundebug)
	end
end

return {
  name = "Shell commands to toolbar",
  description = "",
  author = "rst256",
  version = 0.1,
  dependencies = 1.0,

	onRegister = function(self)
		local settings = self:GetSettings()
		settings.tools = settings.tools or {}
		settings.tools.name = 'usertool'
		show_tools(settings.tools)
--		for k=1, #settings.tools do add_tool(settings.tools, k) end
--		for k, v in ipairs(settings.tools) do
--			local tool_id = G.ID("cmd2toolbar.usertool"..k)
--			ide:GetToolBar():AddTool(tool_id, TR(v.name),
--				wx.wxBitmap(v.icon or '', wx.wxBITMAP_TYPE_ANY ),
--				TR(v.name)
--			)
--			ide:GetMainFrame():Connect(tool_id,
--				wx.wxEVT_COMMAND_MENU_SELECTED, run_tool(v))
--		end

		ide:AddTool(TR'Edit tools list',function()
			makeUI(ide:GetMainFrame(),self)
		end)



--		ide:GetToolBar():Realize()
	end,

	onProjectLoad = function(self, project)
		local project_tools_file = GetPathWithSep(project..'/')..'.zbtools.lua'
		if wx.wxFileExists(project_tools_file) then
			local fn, err = loadfile(project_tools_file)
--			DisplayOutputLn(fn)
--			DisplayOutputLn(err)
			project_tools = fn()
			project_tools.name='project_tools'
--			for idx=1, #project_tools do add_tool(project_tools, idx) end
			show_tools(project_tools)
--			ide:GetToolBar():Realize()
--			ide:GetMainFrame().uimgr:Update()
		end
--		DisplayOutputLn(project_tools_file)
		_onInterpreterLoad(self, ide:GetInterpreter())
	end,

	onProjectClose = function(self)
		if project_tools then
			for idx=1, #project_tools do
				remove_tool(project_tools, idx)
			end
		end
		ide:GetToolBar():Realize()
		ide:GetMainFrame().uimgr:Update()
	end,

	onInterpreterLoad = _onInterpreterLoad,

  onUnRegister = function(self)
		for _, id in pairs(tools_id) do
			ide:GetToolBar():DeleteTool(id)
		end
--		ide:GetToolBar():DeleteTool(cs_toolbar_id)
    ide:GetToolBar():Realize()
		ide:RemoveTool(TR'Edit tools list')
		ide:GetMainFrame().uimgr:Update()
  end,
}

