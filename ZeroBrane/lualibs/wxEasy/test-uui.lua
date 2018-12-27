package.path = "?.lua;../?/init.lua;";
--local print = print;
local inspect = require("inspect");
local wxE = require"wxEasy";

--print(inspect(wxE))
-- local frm1 = wxE.new"frame";
local frm = wxE.frame("frame1");
-- wxE.frame(frm1[0], "frame sub");
--local frm = wxE.new"frame";

frm.new("menu", {file={{5, "new"}, {6, "delete"}}});

    local watchMenu = wx.wxMenu{
            { 44,      "&Add Watch"        },
            { 55,     "&Edit Watch\tF2"   },
            { 66,   "&Remove Watch"     },
            { 77, "Evaluate &Watches" }}

    --~ local watchMenuBar = wx.wxMenuBar()
    --~ watchMenuBar:Append(watchMenu, "&Watches")

frm.menu:Append(watchMenu, "watchMenu")
--frm1[0]:SetMenuBar(frm.menu)

local flexSizer = frm.new("flexSizer", 2, 400, 400);
--print(inspect(frm))
--local tree = frm.new"tree";
local tree = flexSizer.add('tree')(6, wx.wxALIGN_LEFT+wx.wxALL,5);
--print(inspect(tree))
--print(inspect(wxE))
--tree(6, wx.wxALIGN_LEFT+wx.wxALL,50);
tree.toolTip = "Tree toolTip";
--print(inspect(tree))
--local getRoot0 = 'self:getRoot0()\t'..inspect(getmetatable(tree:getRoot()));
local tree_root = tree.addRoot("root", 2, -1);
--print(tree_root);
--tree.addItem(tree_root, "root/sub");
--local tree_node = tree.addItem(tree_root, "root/sub2");
--tree.addItem(tree_node, "root/sub/1");
--tree.addItem(tree_node, "root/sub/2");
tree.setItemData(tree_root, {'tree:root'})
flexSizer.minSize(tree, 300, 500);

do --* button
	local add_button = flexSizer.add("button",0, "BUTTON1")
	function add_button:onClick(event)
		print('add_button:onClick', event)
		tree.addItem(tree_root, "root/new sub");
		--tree.setSize(300, 500);
		--flexSizer.itemSize(tree, 300, 500);
		tree.visible = 0;
		--flexSizer.fit();
		return true;
	end
end
do --* button
	local add_button = flexSizer.add("button",0, "Show")
	function add_button:onClick(event)
		print('add_button:onClick', event)
		tree.addItem(tree_root, "root/new sub");
		tree.show();
		return true;
	end
end

--flexSizer.fit()

function tree:onItemCollaps(event)
--	print('self:getRoot()', tree.items.text, tree.items.data)
		--tree:getItemData(tree:getRoot()));
--  print(self, ".onItemCollaps(", tostring( event), ")");
  --return true;
	--tree.items = "nil"
end


function tree_dump(items, deep)
	local deep = deep or 1
	for k,v in pairs(items) do
		print(string.rep('\t\t', deep), k, v)
		v.bold = 1
		tree_dump(v, deep+1)
	end
end

function tree:onItemExpand(event)
  --print(self, ".onItemExpand(", tostring( event), ")");
  --return true;
	--tree_dump(tree.items)
--	print(tree.items.bold)
end

function tree:onSelChange(event)
--  print(self, ".onSelChange(", tostring( event:GetItem()), ")");
--	for k,v in ipairs(tree.items) do
--		print(k,v)
--	end
--	print(inspect(tree[0]:GetItemData(event:GetItem()):GetData()))
--  return true;

end

function tree:onKeyDown(event)
--  print(self, ".onKeyDown(",  self.getItemText(event:GetItem()), ")");
  --return true;
	tree.items.data = 55 --{'tree.items.data'}
end

function frm:onClose(event)
--  print(self, ".onClose(", event, ")");
end

function frm:onActivate(event)

end


bindingList = wxlua.GetBindings() -- Table of {wxLuaBinding functions}

controlTable   = {} -- Table of { win_id = "win name" }
ignoreControls = {} -- Table of { win_id = "win name" } of controls to ignore events from


wxLuaBinding_wx = nil

do
    local bindTable = wxlua.GetBindings()
    for n = 1, #bindTable do
        if bindTable[n].name == "wx" then
            wxLuaBinding_wx = bindTable[n].binding
            break
        end
    end
end


-- Turn the array from the binding into a lookup table by event type
--~ wxEVT_Array = bindingList[1].GetEventArray
--~ for i = 2, #bindingList do
--~     local evtArr = bindingList[i].GetEventArray
--~     for j = 1, #evtArr do
--~         table.insert(wxEVT_Array, evtArr[j])
--~     end
--~ end

--do
--	local tree_node = tree.addItem(tree_root, "wxEVT_Array");
--	for k,v in pairs(wxEVT_Array) do
--		tree.addItem(tree_node, v.name).data = v;
--	end
--end


--~ wxEVT_List  = {}
--~ wxEVT_TableByType = {}
--~ for i = 1, #wxEVT_Array do
--~     wxEVT_TableByType[wxEVT_Array[i].eventType] = wxEVT_Array[i]
--~     table.insert(wxEVT_List, {wxlua.typename(wxEVT_Array[i].wxluatype), wxEVT_Array[i].name})
--~ end
--~ table.sort(wxEVT_List, function(t1, t2) return t1[1] > t2[1] end)
--print(inspect(wxEVT_TableByType))
do
	local tree_node = tree.addItem(tree_root, "events");
	for mi,m in pairs(bindingList) do
		local t = tree.addItem(tree_node, tostring(mi));
		for _,e in pairs(m.GetEventArray) do
			--print(inspect(e))
			tree.addItem(t, e.eventType..':'..e.name..'/'..e.wxluatype).data = e;
		end
	end
end


-- Turn the array from the binding into a lookup table by class name
wxCLASS_Array = bindingList[1].GetClassArray
for i = 1, #bindingList do
    local classArr = bindingList[i].GetClassArray
    for j = 1, #classArr do
        table.insert(wxCLASS_Array, classArr[j])
    end
end

do
	local tree_node = tree.addItem(tree_root, "wxCLASS_Array");
	for k,v in pairs(wxCLASS_Array) do
		tree.addItem(tree_node,  v.name..'/'..v.wxluatype).data = v;
	end
end



wxCLASS_TableByName = {}
for i = 1, #wxCLASS_Array do
    wxCLASS_TableByName[wxCLASS_Array[i].name] = wxCLASS_Array[i]
end

--local tree_class_node = tree.addItem(tree_root, "wxCLASS_TableByName");
--for k,v in pairs(wxCLASS_TableByName) do
--	tree.addItem(tree_class_node, tostring(k)).data = v;
--end
--print(inspect(wxCLASS_TableByName))


frm.toolTip = "self.toolTip";
frm.show(true);
--frm1.show(true);
wxE.mainLoop();