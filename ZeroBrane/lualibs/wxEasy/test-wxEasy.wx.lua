package.path = "?.lua;../?/init.lua;";
--local print = print;
--local inspect = require("inspect");
local wxE = require"wxEasy";

--print(inspect(wxE))

local frm = wxE.frame("frame");
--wxE.frame(frm1[0], "frame sub");
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
flexSizer.direction=wx.wxHORIZONTAL
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
tree.addItem(tree_root, "root/sub");
local tree_node = tree.addItem(tree_root, "root/sub2");
tree.addItem(tree_node, "root/sub/1");
tree.addItem(tree_node, "root/sub/2");
tree.setItemData(tree_root, {'tree:root'})
flexSizer.minSize(tree, 300, 500);

local flexSizerV = frm.new("flexSizer", 2, 400, 400);

flexSizerV.direction=wx.wxVERTICAL
--do --* button
--	local add_button = flexSizer.add("button",0, "BUTTON1")
--	function add_button:onClick(event)
--		print('add_button:onClick', event)
--		tree.addItem(tree_root, "root/new sub");
--		--tree.setSize(300, 500);
--		--flexSizer.itemSize(tree, 300, 500);
--		tree.visible = 0;
--		--flexSizer.fit();
--		return true;
--	end
--end
--do --* button
local add_button = flexSizerV.add("button",0, "Add Alt")
function add_button:onClick(event)
--	print('add_button:onClick', tree.sel)
	tree.sel.AddChild("root/new sub");
	return true;
end

local insert_button = flexSizerV.add("button",1, "Insert Alt")
function insert_button:onClick(event)
	tree.sel.insert("root/new sub");
	return true;
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
  print(self, ".onSelChange(", tostring( event:GetItem()), ")");
	for k,v in pairs(tree.items) do
		print(k, v, #v)
		for kc,vc in pairs(v) do print('', kc, vc, #vc) end
	end
--	print(inspect(tree[0]:GetItemData(event:GetItem()):GetData()))
  return true;

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



frm.toolTip = "self.toolTip";
frm.show(true);
--frm1.show(true);
wxE.mainLoop();