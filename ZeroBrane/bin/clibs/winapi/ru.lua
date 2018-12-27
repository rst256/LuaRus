--local tt = require'transl-tools'


--local pattern = tt.pattern
--local ident = tt.ident


return {
	pattern"//([^\n]+)\n", 
	pattern"/%*(.-)%*/",
	include'([ \t]*\n+[ \t]*#[ \t]*)вставить([ \t]+)([^\n]+)',
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