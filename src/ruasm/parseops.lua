--local operand_mt = {
--	__tostring=function(self)
--		return (self.input and 'in ' or '')
--			..(self.output and 'out ' or '')
--			..self.optype
--	end
--}
--function operand(optype, mode)
--	local mode = mode or ''
--	local this = {
--		optype=optype,
--		input=(mode:find'i' ~= nil),
--		output=(mode:find'o' ~= nil)
--	}

--	return setmetatable(this, operand_mt)
--end

--x86_64=require("x86_64")


require("LuaXML")
local xfile = xml.load("x86_64.xml")


local xscene = xfile:find("НаборИнструкций")
--for i,x in ipairs(xscene[1]) do
--	print(i, tostring(x):sub(1,15))
--	for k,v in pairs(x) do
--		if type(k)=='string' then
--			print('--', k,v)
--		elseif k>0 then
--			print('--', k,tostring(v):sub(1,15))
--		end
--	end
--end
local out = io.open("x86_64.lua", 'w')
out:write('return {\n')
for i,x in ipairs(xscene) do
	print(x['name']..': '..x.summary)
	out:write('["'..x['name']..'"]={\n\t["описание"]="'..
		x.summary..'",')
	for k,v in ipairs(x) do
		out:write('\n\t{ ["имя"]="'..v['gas-name']..'"')
		if v['nacl-version'] then
			out:write(',\n\t\t["версия"]='..v['nacl-version'])
		end
		out:write(',\n\t\t["операнды"]={')
		local ops = ''
		local coding
		for _,o in ipairs(v) do
			if o:tag()=='Операнд' then
--				out:write('\n\t\t\t{type="'..o['тип']
--					..'", input='..tostring(o['ввод']=='да')
--					..', output='..tostring(o['вывод']=='да')..'},')
				out:write('\n\t\t\tоп("'..o['тип']..'", "'
					..(o['ввод']=='да' and 'i' or '')
					..(o['вывод']=='да' and 'o' or '')
					..'"),')
					ops = ops..(o['ввод']=='да' and 'in ' or '')..
				(o['вывод']=='да' and 'out ' or '')..
				o['тип']..', '
			elseif o:tag()=='Кодирование' then
				coding = o
			end
		end
		out:write('\n\t\t},')
		out:write('\n\t\t["кодирование"]={')
		for _,c in ipairs(coding) do
			if c:tag()=='Опкод' then
				out:write('\n\t\t\t["опкод"]=0x'..c['byte']..',')
			else
				out:write('\n\t\t\t["'..c:tag()..'"]={')
				for n,r in pairs(c) do
					if n~=0 then
						out:write('["'..n..'"]="'..r..'", ')
					end
				end
				out:write('},')
			end
		end
		out:write('\n\t\t},\n\t},')
		print('', v['gas-name'], ops:sub(1,-3))
	end
	out:write('\n},')
end
out:write('\n}')
print'----'
