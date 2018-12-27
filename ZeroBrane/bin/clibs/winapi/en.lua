--local tt = require'transl-tools'


--local pattern = tt.pattern
--local ident = tt.ident
--local include = tt.include
--local preproc = tt.preproc


return {
	pattern"//([^\n]+)\n", 
	pattern"/%*(.-)%*/",
	include'([ \t]*\n+[ \t]*#[ \t]*)include([ \t]+)([^\n]+)',
	preproc'([ \t]*\n+[ \t]*#[ \t]*)(%a+)',	
	pattern'%s+',
	ident'([%a_]+%w*)',
	pattern'(0x[%x]+)',
	pattern'%d*%.?%d+[eE][%+%-]?%d+',		
	pattern'%d*%.%d+',
	pattern'%d+',		
	pattern'"[^\n]-[^\\]"', 
	pattern'"[^"\n]*"',
	pattern"'[^\n]-[^\\]'", 
	pattern"'[^'\n]*'",	
	pattern"[%+%-%*&|=<>/%(%){}%[%];,:%%!%?%.]",
}