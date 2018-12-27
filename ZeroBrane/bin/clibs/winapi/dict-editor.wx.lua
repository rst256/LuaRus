-----------------------------------------------------------------------------
-- Name:        grid.wx.lua
-- Purpose:     wxGrid wxLua sample
-- Author:      J Winwood
-- Created:     January 2002
-- Copyright:   (c) 2002 Lomtick Software. All rights reserved.
-- Licence:     wxWidgets licence
-----------------------------------------------------------------------------

-- Load the wxLua module, does nothing if running from wxLua, wxLuaFreeze, or wxLuaEdit
--package.cpath = package.cpath..";./?.dll;./?.so;../lib/?.so;../lib/vc_dll/?.dll;../lib/bcc_dll/?.dll;../lib/mingw_dll/?.dll;"
require("wx")

local frame = wx.wxFrame(wx.NULL, wx.wxID_ANY, "wxLua wxGrid Sample",
                         wx.wxPoint(225, 25), wx.wxSize(750, 650))

local Editor = { OpenDicts={} }

local Config = { 
	DictLanguages={ 'en', 'ru' },
	SourceFileTypes="C files (*.c)|*.c|Header files (*.h)|*.h|All files (*)|*",
}

local function getDictCol(dict, grid, create_if_not_exists)
	local cols = grid:GetNumberCols()
	for col=0,cols-1 do
		if grid:GetColLabelValue(col)==dict then return col end
	end
	if create_if_not_exists then
		grid:InsertCols(cols)
		grid:SetColLabelValue(cols, dict)
		return cols
	end
end

local function OpenFileDialog()
	local path
	local fileDialog = wx.wxFileDialog(frame, "Open file", "", "", 
		Config.SourceFileTypes,
--		"Header files (*.h)|*.h|C files (*.c)|*.c|All files (*)|*",
		wx.wxFD_OPEN --+ wx.wxFD_FILE_MUST_EXIST
	)
	if fileDialog:ShowModal() == wx.wxID_OK then
		path = fileDialog:GetPath()
	end
	fileDialog:Destroy()
	return path
end


local function CreateMenu(items, menu)
	local menuObj = menu or wx.wxMenu("", wx.wxMENU_TEAROFF)
	if type(items[2])=='table' then
		local submenuObj = wx.wxMenu("", wx.wxMENU_TEAROFF)
		for _, item in ipairs(items) do CreateMenu(item, submenuObj) end
		menuObj:AppendSubMenu(submenuObj, items[1])
	else
		local m = menuObj:Append(items[3] or wx.wxID_ANY, items[1], items[4])
		frame:Connect(m:GetId(), wx.wxEVT_COMMAND_MENU_SELECTED, items[2])
	end
	return menuObj
end

local function CreateMenuBar(menus, bar)
	local menuBar = bar or wx.wxMenuBar()
--	CreateMenu(menus, menuBar)
	for _, items in ipairs(menus) do
		local menu = wx.wxMenu("", wx.wxMENU_TEAROFF)
		CreateMenu(items[2], menu)
		menuBar:Append(menu, items[1])
	end
	return menuBar
end


local fileMenu = wx.wxMenu("", wx.wxMENU_TEAROFF)
fileMenu:Append(wx.wxID_OPEN, "O&pen\tCtrl-O", "Open dictionary")
fileMenu:Append(wx.wxID_SAVE, "S&ave\tCtrl-S", "Save dictionary")
fileMenu:Append(wx.wxID_SAVEAS, "Sav&e as...\tCtrl-V", "Save dictionary as...")
local addFromSource=fileMenu:Append(wx.wxID_ANY, "Add N&ew words...\tCtrl-N", "")
fileMenu:Append(wx.wxID_EXIT, "E&xit\tCtrl-X", "Quit the program")

local editMenu = wx.wxMenu{
	{ wx.wxID_ADD, "A&dd word\tCtrl-A", "Add a new word" },
	{ wx.wxID_REMOVE , "Remove& word\tCtrl-E", "Remove the word" },
	{ wx.wxID_REVERT, 'Invert' },
	{ 7002, 'Remove untraslated items' },
	{wx.wxID_SELECTALL, 'Select all' },
	{7003, 'Check' },	
}


local addDictMenu = wx.wxMenu()
local function genAddDictAction(dict)
	return function(event)
		getDictCol(dict, Editor:GetOpenDict().grid, true)
	end
end
--local addDictMenuTable = {}
for i, dict in ipairs(Config.DictLanguages) do
	local menu_item = addDictMenu:Append(wx.wxID_ANY, dict)
	frame:Connect(menu_item:GetId(), wx.wxEVT_COMMAND_MENU_SELECTED, genAddDictAction(dict))
--	addDictMenuTable[dict] = menu_item
end
editMenu:Append(wx.wxID_ANY,"Ad&d dictionary\tCtrl-D", addDictMenu, "Add a new dictionary")


local helpMenu = wx.wxMenu("", wx.wxMENU_TEAROFF)
helpMenu:Append(wx.wxID_ABOUT, "&About\tCtrl-A", "About the Grid wxLua Application")

local menuBar = wx.wxMenuBar()
menuBar:Append(fileMenu, "&File")
--CreateMenuBar({{
--	'View', {
--		{ 'View1', function(event) print'View1' end },
--		{ 'View2', function(event) print'View1' end },
--	}
--}}, menuBar)

menuBar:Append(editMenu, "&Edit")
menuBar:Append(helpMenu, "&Help")

frame:SetMenuBar(menuBar)

frame:CreateStatusBar(1)
frame:SetStatusText("Welcome to wxLua.")


frame:Connect(wx.wxID_OPEN, wx.wxEVT_COMMAND_MENU_SELECTED, function (event)
  Editor:Open()
end)

frame:Connect(addFromSource:GetId(), wx.wxEVT_COMMAND_MENU_SELECTED, function (event)
	local grid=Editor:GetOpenDict().grid
	local src_filename = OpenFileDialog()
	if not src_filename then return end
		
	local file = io.open(src_filename)
	local src = file:read'*l'
	file:close()
	local from = string.match(src, '^[ \t]*//##%s*(%a+)') 
	if not from then 
		wx.wxMessageBox('Can\'t parse source, language is not defined')
		return
	end
	
	for _,to in ipairs(Config.DictLanguages) do
--		local to = grid:GetColLabelValue(col)
		if to~=from then 
			Editor:AddNewWordsFromSource(grid, src_filename, from, to)
		end
	end
	
	
--	local nw_filename = [[C:\Projects\transl\newwords.tmp]]--os.tmpname()
--	local cmd = [[
--	C:\ZeroBrane\bin\lua53.exe C:\Projects\transl\newword_transl.lua ru ]]..
--		src_filename..' '..nw_filename
--	os.execute(cmd)
--	file=io.open(nw_filename)
--	local col, row = getDictCol('en', grid, true), grid:GetNumberRows()
--	for line in file:lines() do 
--		if row==grid:GetNumberRows() then grid:InsertRows(row) end
--		grid:SetCellValue(row, col, wx.wxString.FromUTF8(line))
--		grid:SetRowLabelValue(row, (row+1)..'*')
--		row = row+1
--	end
--	grid:AutoSizeColumns()
--	file:close()
end)

frame:Connect(wx.wxID_SAVE, wx.wxEVT_COMMAND_MENU_SELECTED, function (event)
	Editor:Save()
end)	

frame:Connect(wx.wxID_SAVEAS, wx.wxEVT_COMMAND_MENU_SELECTED, function (event)
	local path = OpenFileDialog()
	if path then Editor:Save(false, path) end
end)	

frame:Connect(wx.wxID_ADD, wx.wxEVT_COMMAND_MENU_SELECTED, function (event)
  local grid=Editor:GetOpenDict().grid
	grid:InsertRows(grid:GetNumberRows())
end)	

frame:Connect(wx.wxID_REMOVE, wx.wxEVT_COMMAND_MENU_SELECTED, function (event)
  local grid=Editor:GetOpenDict().grid
	local sel=grid:GetSelectedRows()
	for k=0,sel:GetCount()-1 do grid:DeleteRows(sel:Item(k)-k) end --fixme
	grid:ClearSelection()
end)	

frame:Connect(7002, wx.wxEVT_COMMAND_MENU_SELECTED, function (event)
  local grid=Editor:GetOpenDict().grid
	local sel, del_count=(grid:GetSelectedRows()), 0
	for k=0,sel:GetCount()-1 do 
--		if 
		local row, transl_count = sel:Item(k)-del_count, 0
		for col=0,grid:GetNumberCols()-1 do
			local val = grid:GetCellValue(row, col)
			if val and val~='' then --:find'^%s*$'
				transl_count = transl_count+1
			end
--			io.write(val..'\t')
		end
--		io.write('='..transl_count..'\n')
--		assert(transl_count>0)
--		if transl_count==0 then print(row+1, sel:Item(k), del_count) end
		if transl_count==1 then 
			grid:DeleteRows(row) 
			del_count = del_count+1--fixme
		end
	end 
	grid:ClearSelection()
end)	

frame:Connect(wx.wxID_SELECTALL, wx.wxEVT_COMMAND_MENU_SELECTED, function (event)
  Editor:GetOpenDict().grid:SelectAll()
end)		

frame:Connect(7003, wx.wxEVT_COMMAND_MENU_SELECTED, function (event)
	local res, err_msg = Editor:Check()
	if res then 
		wx.wxMessageBox('Dictionary has no error')
	else
		wx.wxMessageBox('Found error in dictionary\n'..err_msg)
	end

end)		

frame:Connect(wx.wxID_EXIT, wx.wxEVT_COMMAND_MENU_SELECTED,
    function (event)
        frame:Close()
    end )

notebook = wx.wxNotebook(frame, wx.wxID_ANY, wx.wxDefaultPosition, 
	wx.wxDefaultSize, wx.wxCLIP_CHILDREN)


frame:Connect(wx.wxID_ABOUT, wx.wxEVT_COMMAND_MENU_SELECTED, function (event)
  wx.wxMessageBox('This is the "About" dialog of the wxGrid wxLua sample.\n'..
		wxlua.wxLUA_VERSION_STRING.." built with "..wx.wxVERSION_STRING,
		"About wxLua", wx.wxOK + wx.wxICON_INFORMATION, frame)
end )



function Editor:AddNewWordsFromSource(grid, src_filename, from, to)
	local nw_filename = 'newwords.tmp'
	local cmd = [[
	C:\ZeroBrane\bin\lua53.exe C:\Projects\transl\newword_transl.lua ]]..
		to..' '..src_filename..' '..nw_filename
	os.execute(cmd)
	file=io.open(nw_filename)
	local col, row = getDictCol(from, grid, true), grid:GetNumberRows()
	for line in file:lines() do 
		if row==grid:GetNumberRows() then grid:InsertRows(row) end
		grid:SetCellValue(row, col, wx.wxString.FromUTF8(line))
		grid:SetRowLabelValue(row, (row+1)..'*')
		row = row+1
	end
	grid:AutoSizeColumns()
	file:close()

end

function Editor:Check(selection)
	local grid = Editor:GetOpenDict(selection).grid
	local dt = {}
	for col=0,grid:GetNumberCols()-1 do
		dt[grid:GetColLabelValue(col)] = {}
		local dict = grid:GetColLabelValue(col)
		for row=0,grid:GetNumberRows()-1 do
			local val = grid:GetCellValue(row, col)
			local dt_val = dt[val]
			if dt_val==nil then dt[val] = row
			elseif dt_val==row then
			else 
				return false, ('Rows '..(dt_val+1)..' and '..
					(row+1)..' contain the same words "'..val..'"')
			end	
		end
	end
	return true
end	
	
function Editor:Open(path)
	local path = path or OpenFileDialog()
	if not path then return end
	local grid = wx.wxGrid(notebook, wx.wxID_ANY)
	grid:CreateGrid(0, 0)
	for _, dict in ipairs(Config.DictLanguages) do
		local file = io.open(path..'.'..dict)
		if file then
			local col, row = grid:GetNumberCols(), 0
			grid:InsertCols(col)
			grid:SetColLabelValue(col, dict)
			for line in file:lines() do 
				if row==grid:GetNumberRows() then grid:InsertRows(row) end
				grid:SetCellValue(row, col, wx.wxString.FromUTF8(line))
				row = row+1
			end
			file:close()
		end
	end
	frame:Connect(grid:GetId(), wx.wxEVT_GRID_CELL_CHANGED, function (event)
		local _d=Editor.OpenDicts[event:GetId()]
		_d.isModified = true
		notebook:SetPageText(_d.index, _d.path..' *')
--		print(_d.path)
	end)	
	grid:SetSelectionMode(1)
	grid:AutoSizeColumns()
	notebook:AddPage(grid, path, true)
	self.OpenDicts[grid:GetId()] = { 
		path=path, grid=grid, isModified=false,
		index=notebook:GetSelection() 
	}
end

function Editor:GetOpenDict(selection)
  if not selection then selection = notebook:GetSelection() end
  if (selection >= 0) and (selection < notebook:GetPageCount()) then
    return self.OpenDicts[notebook:GetPage(selection):GetId()]
  end
end

function Editor:Save(selection, path)
	local res, err_msg = Editor:Check()
	if not res then 
		wx.wxMessageBox('Save failed. Error in dictionary:\n'..err_msg)
		return
	end	
	local _d = Editor:GetOpenDict(selection)
	local grid, path = _d.grid, (path or _d.path)
	for col=0,grid:GetNumberCols()-1 do
		local file = io.open(path..'.'..grid:GetColLabelValue(col), 'w+')
		if not file then 
			error('open file: '..path..'.'..grid:GetColLabelValue(col)) 
		end
		for row=0,grid:GetNumberRows()-1 do
			file:write(grid:GetCellValue(row, col)..'\n')
		end
		file:close()
	end
	_d.isModified = false
	notebook:SetPageText(_d.index, _d.path)	
end

--grid:CreateGrid(10, 8)
----grid:SetColSize(3, 200)
----grid:SetRowSize(4, 45)
--grid:SetCellValue(0, 0, "First cell")
--grid:SetCellValue(0, 1, "Another cell")
--grid:SetCellValue(2, 2, "Yet another cell")
----grid:SetCellFont(0, 0, wx.wxFont(10, wx.wxROMAN, wx.wxITALIC, wx.wxNORMAL))
----grid:SetCellTextColour(1, 1, wx.wxRED)
----grid:SetCellBackgroundColour(2, 2, wx.wxCYAN)
--grid:SetColLabelValue(1, 'en')

Editor:Open'test/utf8.h'
Editor:Open'skins/stdio.h'

frame:Show(true)
--wx.wxGetApp():MainLoop()
-- Call wx.wxGetApp():MainLoop() last to start the wxWidgets event loop,
-- otherwise the wxLua program will exit immediately.
-- Does nothing if running from wxLua, wxLuaFreeze, or wxLuaEdit since the
-- MainLoop is already running or will be started by the C++ program.
wx.wxGetApp():MainLoop()
