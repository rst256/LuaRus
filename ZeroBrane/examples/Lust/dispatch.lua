if not loadstring then
	function loadstring(code) return load(code, '', 't', _G) end
end







local Lust = require"Lust"

local function nl(str) return string.gsub(str, [[\n]], "\n"):gsub([[\t]], "\t") end

local temp = Lust{
	[1] = "@dispatch",
	dispatch = [[@if(rule)<{{@(rule)}}>else<{{$1}}>]],
	statlist = nl[[@map{statements, _="\n"}:dispatch]],
	stat = [[@if(outputs)<{{@map{outputs, _=","}:dispatch = }}>@map{inputs, _=","}:dispatch;]],
	binop = [[@map{inputs, _=op}:dispatch]],
	fcall = [[$name(@map{inputs, _=", "}:dispatch)]],

	get_token = [[(get_next_token($source, @if(opts)<{{$opts}}>else<{{0}}>))]],
}

print(temp:gen{
	rule = "statlist",
	statements = {
		{
			rule = "stat",
			outputs = {"res1"},
			inputs = {
				{
					rule = "binop",
					op = "+",
					inputs = {
						{
							rule = "binop",
							op="*",
							inputs = {"a", "b"},
						},
						"c"
					}
				},
			}
		},
		{
			rule = "stat",
			inputs = {
				{
					rule = "fcall",
					name = "test",
					inputs = {1, 2, 3},
				},
			}
		},
		{
			rule = "stat",
			inputs = {
				{
					rule = "get_token",
					source = "Src",
					opts = 0x0b,
				},
			}
		}
	}
})