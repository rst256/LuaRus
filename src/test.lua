
функция создать_метатип(опред)
	возврат опред
конец

функция зарегистрировать_тип(тип, имя_класса)

конец


класс = [[ "класс" имя_класса:имя 
	":" ? базовые_классы:(имя*",") 
	члены_класса:(блок определение_функции / определение_переменной )
]]

локал Тип = создать_метатип{ 
	вызов_поля = функция(я, имя, ...)
		локал член = члены_класса.симтаб[имя]
		если член == нуль тогда 
			ошибка()
		иначеесли член.род == "функция" тогда 
			возврат код_вызова_функции(имя_класса.."__"..имя, я, ...)
		иначеесли член.род == "переменная" тогда 
			ошибка"вызов свойства как метода"
		конец
	конец,

	запись_значения_поля = функция(я, имя, значение)
		локал член = члены_класса.симтаб[имя]
		если член == нуль тогда 
			ошибка()
		иначеесли член.род == "функция" тогда 
			ошибка"присваивание методу"
		иначеесли член.род == "переменная" тогда 
			возврат код_присваивания(код_поле_структуры(я, имя), значение)
		конец
	конец,

	чтение_значения_поля = функция(я, имя)
		локал член = члены_класса.симтаб[имя]
		если член == нуль тогда 
			ошибка()
		иначеесли член.род == "функция" тогда 
			ошибка"чтение метода"
		иначеесли член.род == "переменная" тогда 
			возврат код_поле_структуры(я, имя)
		конец
	конец,

	реальное_описание_типа = функция()
		локал свойства = {}
		для н, св из pairs(члены_класса.симтаб) начало
			если св.род == "переменная" тогда свойства[н] = св.тип конец
		конец
		возврат код_описание_типа_структуры(свойства)
	конец,

	
}	

зарегистрировать_тип(тип, имя_класса)

печать(тип)




-- 
-- 
-- mixin PoweredDevice{
-- 	int is_pwr_on;
-- 	public:
-- 		void power_on (void){ is_pwr_on=1; }
-- 		void power_off(void){ is_pwr_on=0; }
-- 		int power_state(void){ return is_pwr_on; }		
-- };
--  
-- class Scanner : public PoweredDevice{
-- 	public:
-- 		image scan();
-- };
--  
-- class Printer : public PoweredDevice{
-- 	public:
-- 		void print(document doc){ print_raw(doc); }
-- };
--  
-- class MFU : public Printer, public Scanner
-- {
--     int fieldD;
-- };
-- 
-- 
-- 
-- 
-- 
-- 
-- 
-- 
-- 
-- 


-- утв(ложь)

печать"привет мир"

печать("\xd0\xbf\xd0\xb5\xd1\x80\xd0\xb5\xd1\x87\xd0\xb8\xd1\x81\xd0\xbb\xd0\xb8", истина или ложь, истина и 666)

-- строка=вв.ввод:читать('л')
-- печать("строка:", строка)
-- 
-- число=вв.ввод:читать('н')
-- печать("число:", число)

функция требстр(итер, ток)
	локал л,с,н,к = итер()
	если л=="ws" тогда л,с,н,к = итер() конец
	если с~=ток тогда ощибка("синт. ошибка: ожидается "..ток.." получен "..с) конец
конец

функция тестстр(итер, ток)
	локал итер_поз = строка.токитер_запомнить(итер)
	локал л,с = итер()
	если л=="ws" тогда л,с = итер() конец
	если с~=ток тогда 
		строка.токитер_вернуть(итер, итер_поз)
		возврат ложь 
	конец
	возврат истина
конец

функция тестспис(итер, ток)
	локал итер_поз = строка.токитер_запомнить(итер)
	локал л,с = итер()
	если л=="ws" тогда л,с = итер() конец
	если ток:найти(с) тогда 
		возврат с
	конец
	строка.токитер_вернуть(итер, итер_поз)
	возврат ложь
конец

функция тестток(итер, ток)
	локал итер_поз = строка.токитер_запомнить(итер)
	локал л, с = итер()
	если л=="ws" тогда л, с = итер() конец
	если л~=ток тогда 
		строка.токитер_вернуть(итер, итер_поз)
		возврат ложь 
	конец
	возврат с
конец

функция П(...)
	локал посл = {...}
	возврат функция(итер)
		локал итер_поз = строка.токитер_запомнить(итер)
		для инд, элем из перечисли(посл)
			если не элем(итер) тогда 
				строка.токитер_вернуть(итер, итер_поз)
				возврат ложь 
			конец
		конец
		возврат истина
	конец
конец

функция А(...)
	локал альт = {...}
	возврат функция(итер)
		локал итер_поз = строка.токитер_запомнить(итер)
		для инд, элем из перечисли(альт)
			если элем(итер) тогда возврат истина конец
			строка.токитер_вернуть(итер, итер_поз)
		конец
		возврат ложь
	конец
конец

функция Л(лекс)
	возврат функция(итер)
		локал л, с = итер()
		если л=="ws" тогда л, с = итер() конец
		если л==лекс тогда возврат с конец
		возврат ложь
	конец
конец

функция С(стр)
	возврат функция(итер)
		локал л, с = итер()
		если л=="ws" тогда л, с = итер() конец
		если с==стр тогда возврат истина конец
		возврат ложь
	конец
конец


функция О(правило)
	возврат функция(итер)
		локал итер_поз = строка.токитер_запомнить(итер)
		если не правило(итер) тогда строка.токитер_вернуть(итер, итер_поз) конец
		возврат истина
	конец
конец

функция Ц(правило)
	возврат функция(итер)
		локал итер_поз, рез = строка.токитер_запомнить(итер), ложь
		пока правило(итер) 
			итер_поз = строка.токитер_запомнить(итер)
			рез = истина
		конец
		строка.токитер_вернуть(итер, итер_поз)
		возврат рез
	конец
конец

правила = {}
функция И(имя)
	возврат функция(итер)
		возврат правила[имя](итер)
	конец
конец





ид = Л"id"
функция начать_разбор(итер)
	локал итер_поз = строка.токитер_запомнить(итер)
	локал л, с, н, к = итер()
	если л=="ws" тогда л, с, н, к = итер() конец	
	возврат итер_поз, л, с, н, к
конец

функция СписокСРазделителями(элем, разд, непустой)
	возврат функция(итер)
		локал список = {}
		локал арг = элем(итер)
		если арг тогда 
			table.insert(список, арг)
			пока тестстр(итер, разд)
				локал арг = элем(итер)
				если не арг тогда ощибка("отсутствует аргумент") конец
				table.insert(список, арг)
			конец
		иначеесли непустой тогда
			ощибка("отсутствуют аргументы")
		конец
		возврат список
	конец
конец

функция СписокСОкончанием(элем, оконч, непустой)
	возврат функция(итер)
		локал список = {}
		пока не тестстр(итер, оконч)
			локал арг = элем(итер)
			если не арг тогда ощибка("отсутствует аргумент") конец
			table.insert(список, арг)
		конец
		если непустой и №список==0 тогда
			ощибка("отсутствуют аргументы")
		конец
		возврат список
	конец
конец

функция Список(элем, непустой)
	возврат функция(итер)
		локал список = {}
		локал арг = элем(итер)
		пока арг
			table.insert(список, арг)
			арг = элем(итер)
		конец
		если непустой и №список==0 тогда
			ощибка("отсутствуют аргументы")
		конец
		возврат список
	конец
конец

функция Значение1(итер)
	локал итер_поз, л, с = начать_разбор(итер)


	если л=="id" тогда
		если тестстр(итер, "(") тогда
			локал аргументы = СписокЗначений(итер)
			требстр(итер, ")")
			возврат ""..с.."("..table.concat(аргументы, ', ')..")"
		-- иначеесли тестстр(итер, "[") тогда
			
		иначе
			возврат ""..с
		конец
	иначеесли л=="num" тогда
		возврат ""..с
	иначеесли л=="str" тогда
		возврат ""..с
	конец

	строка.токитер_вернуть(итер, итер_поз)
	возврат ложь
конец

функция Значение2(итер)
	локал итер_поз = строка.токитер_запомнить(итер)


	если тестстр(итер, "(") тогда
		локал а = Значение(итер)
		требстр(итер, ")")
		возврат "("..а..")"
	конец

	локал опер = тестспис(итер, "не   #     -     ~")
	если опер тогда
		локал а = ПриоритетОпераций(Значение2, "^")(итер)
		если не а тогда ощибка("отсутствует операнд") конец
		возврат "("..опер.." "..а..")"
	-- иначеесли тестстр(итер, "[") тогда
	иначе
		локал а = Значение1(итер)
		возврат а
	конец

	строка.токитер_вернуть(итер, итер_поз)
	возврат ложь
конец



функция ПриоритетОпераций(значение, операции, ...)
	если не операции тогда возврат значение конец
	локал функция опер_фн(итер)
		локал итер_поз = строка.токитер_запомнить(итер)
		локал а = значение(итер)
		если а тогда
			локал опер = тестспис(итер, операции)
			если опер тогда
				локал б = опер_фн(итер)
				если не б тогда ощибка("отсутствует второй операнд") конец
				возврат "("..а.." "..опер.." "..б..")"
			-- иначеесли тестстр(итер, "[") тогда
			иначе
				возврат а
			конец
		конец
	
		строка.токитер_вернуть(итер, итер_поз)
		возврат ложь
	конец
	возврат ПриоритетОпераций(опер_фн, ...)
конец

Значение = ПриоритетОпераций(Значение2, "* / // %", "+ -", "..", "<< >>", "&", "~", "|", "< > <= <= == ~=", "и", "или")
СписокЗначений = СписокСРазделителями(Значение, ",")
СписокАргументов = СписокСРазделителями(ид, ",")

функция отступы(список)
	локал с = ""
	для инд, элем из перечисли(список)
		с = "\t"..элем.."\n"
	конец
	возврат с
конец

функция отступ(стр)
	-- локал с = ""
	-- для инд, элем из перечисли(список)
	-- 	с = "\t"..элем.."\n"
	-- конец
	возврат (стр:gsub("([^\n]*)", "\t%1"))
конец

функция Предложение(итер)
	локал итер_поз, л, с = начать_разбор(итер)
	если л=="id" тогда
		если с=="если" тогда
			локал усл = Значение(итер)
			требстр(итер, "тогда")
			локал блок_тогда, блок_иначе = код(итер)
			если тестстр(итер, "иначе") тогда
				блок_иначе = код(итер)
			конец
			требстр(итер, "конец")
			возврат "if "..усл.." then \n"..отступ(table.concat(блок_тогда, "\n"))..
				(блок_иначе и ("\nelse \n"..отступ(table.concat(блок_иначе, "\n"))) или "").."\nend "
		иначеесли с=="пока" тогда
			локал усл = Значение(итер)
			тестстр(итер, "начало")
			локал тело_цикла = блок(итер)
			возврат "while "..усл.." do \n"..отступ(table.concat(тело_цикла, "\n")).."\nend "
		иначеесли с=="функция" тогда
			локал имя = ид(итер)
			требстр(итер, "(")
			локал аргументы = СписокАргументов(итер)
			требстр(итер, ")")
			локал тело_фн = блок(итер)
			возврат "function "..имя.."("..table.concat(аргументы, ', ')..")\n"..отступ(table.concat(тело_фн, "\n")).."\nend "
		иначеесли тестстр(итер, "(") тогда
			локал аргументы = СписокЗначений(итер)
			требстр(итер, ")")
			возврат ""..с.."("..table.concat(аргументы, ', ')..")"
		иначеесли тестстр(итер, "=") тогда
			локал знач = Значение(итер)
			если не знач тогда ощибка("отсутствует присваиваемое значение") конец
			возврат ""..с.." = "..знач
		конец
	конец

	строка.токитер_вернуть(итер, итер_поз)
	возврат ложь
конец

блок=СписокСОкончанием(Предложение, "конец")
код=Список(Предложение, истина)
значение = А(И"вызов", Л"num", Л"str", ид)
значения = П(значение, О(Ц(П(С",", значение))))
вызов = П(ид, С"(", значения, С")")
правила.вызов = вызов


класс1 = [[класс( "cnh",77 ,	"", фн(7), ф())x= 5*9+7-1/2^3 
функция ф1(х) 
	если ф(х) тогда 
		х=0 
	иначе 
		х=(фн(666)) 
		если х<=0 тогда 
			х=666 
			print(-7^-2^(-1*2)*-2+-(2+2/3))
			пока  x>0 и z~=0 или у~=0 
						х = (х)-(1 )
			конец 
			w = не true или false и true
		конец
	конец 
конец 
яя22 5554"класс" ... --
@macro1( 5, 8, "ккк", макро0(7, "стр"),666))@macro0 ()]]
итер_ток = класс1:токениз("")
print(table.concat(код(итер_ток), "\n"), "\n", итер_ток())

print(debug.getupvalue(итер_ток, 3))
итер_ток_поз = строка.токитер_запомнить(итер_ток)
print(итер_ток())
строка.токитер_вернуть(итер_ток, итер_ток_поз)
print(итер_ток())
prev_s = nil
for l,s,b,e in итер_ток do 
	
	if prev_s=='@' and l=='id' then
		требстр(итер_ток, "(")
		print('macros:', s) 
		local lev = 0
		local arg, args = '', {}
		for l,s in итер_ток 
			arg = arg .. s
--печать(s, lev, arg)
			if s=='(' then lev=lev+1;
			elseif s==')' then if lev==0 then table.insert(args, arg:подстр(1,-2)); arg = ''; break; else lev=lev-1; end
			elseif s==',' and lev==0 then table.insert(args, arg:подстр(1,-2)); arg = '';  
			end

		end

печать(table.concat(args, ', '))

	end
	prev_s = s
end

ос.выход()
для н, т из пар(_ОКР) 
	если тип(т)=="таблица" и н:найти"^[%r_]" тогда 
		печать(н)
		для н2, т2 из пар(т) начало
			 если н2:найти"^[%r_]" тогда печать("", н2) конец
		конец
	конец
конец
печать""
для н, т из пар(_ОКР) начало
	если тип(т)=="функция" и н:найти"^[%r_]" тогда 
		печать(н)
	конец
конец

печать""
-- локал русские_метаметоды = { 
-- 	-- __новый="__newindex",
-- 	-- __индекс="__index",
-- 	-- __длина="__len",
-- 	-- __вызов="__call",
-- 
-- }
-- функция устметатаб(таб, мт)
-- 	локал мт_англ = {}
-- 	для н, в из пар(мт) начало
-- 		-- локал рн = русские_метаметоды[н]
-- 		мт_англ[русские_метаметоды[н] или н] = в
-- 		-- если рн тогда мт_англ[рн] = в иначе  конец
-- 	конец
-- 	возврат setmetatable(таб, мт_англ)
-- конец 



устметатаб(_ОКР, {
	__новый=функция(...) печать(...) конец,
	__вызов=функция(...) печать(...) конец,
	__индекс=функция(...) печать(...) конец,
	__длина=функция(...) печать(...) возврат 666 конец,
	__умнож=функция(...) печать(...) возврат -666 конец,
})

_ОКР.новпер = "новпер"
печать(_ОКР.поле1)
печать(№_ОКР)
_ОКР(1,2,666)
печать(_ОКР*{})
локал счетчик=10
пока счетчик>0 
	печать('счетчик', счетчик)
	счетчик=счетчик-1
конец
ос.выход()

файл = вв.построчно("test.lua1", "r")
весьфайл=файл:читать('в')
печать("весь файл", весьфайл)


-- os.execute'chcp 65001'
print'привет мир'
print'\208\191\209\128\208\184\208\178\208\181\209\130'
_G['\x5F\xD0\x9E\xD0\x9A\xD0\xA0']=_G
_ОКР['печать']('\208\191\209\128\208\184\208\178\208\181\209\130')
os.execute'chcp 1251'
print'\xF4\xF3\xED\xEA\xF6\xE8\xFF'

-- печать=print
печать'\208\191\209\128\208\184\208\178\208\181\209\130'
печать'"\150" "\208"'
-- локал 

функция таблица(c)
	возврат {}
конец

функция тип(арг)
	возврат type(арг)
конец

мт = {}
функция мт.__новыйид(окр, арг)
	если тип(арг)=='table' тогда
		локал т = {}
		for k,v in pairs(getmetatable(окр) or {}) do
			if k=='__index' then 
				т[k] = function(r, k) return rawget(арг, k) or окр[k] end
			elseif k=='__newindex' then
				т[k] = function(r, k, v) арг[k] = v end
			else
				т[k] = v
			end
		end
		т.__index = function(r, k) return rawget(арг, k) or окр[k] end 
		т.__newindex = function(r, k, v) print(r,k,v) арг[k] = v end
		возврат setmetatable({}, т), арг
	конец
конец
локал функции
_G, функции = мт.__новыйид(_G, таблица())
local v=666
функция мт:__add( а, б )
конец
local vv=666
do
local vvv=777
-- print(debug.getupvalue(-1, 1), debug.getlocal(1, 1))
end
функция разбор_строки(c)
-- for i=128,191 do print(i, '"'..c..string.char(i)..'"') end




конец
разбор_строки''
разбор_строки"\208"
tt=777
-- 
-- функция(шаблон) 
-- конец)

for c, i in pairs(функции) do print(c, i) end



-- for i=32,191 do print(i, '`'..string.char(i)..'`', '"\208'..string.char(i)..'"') end




-- 
-- 
-- печать(require"луахмл")
-- 
-- 
--  ос.выход()
-- 
-- 
-- 
-- 
-- печать('os.устлокаль()', ос.устлокаль())
-- ос.устлокаль('ru', 'all')
-- печать('os.устлокаль()', ос.устлокаль())
-- ос.выполнить'chcp'
-- 
-- ос.выполнить'@chcp 1251'
-- ллл=9
-- 
-- кон={}
-- кон.печать=печать
-- кон.печать'ллл='
-- печать(ллл)
-- печать(_окр, _ВЕРСИЯ)
-- печать(_окр==_g, _версия==_version)
-- печать(тип(_версия), #_окр)
-- если _версия!="луа 5.3" тогда
-- 	печать"версия - ок"
-- иначе
-- 	печать"версия - сбой"
-- конец
-- 
-- локал фмт = "%-20с: %с %4б"
-- для к,з из пары(_окр) начало
-- 	печать(фмт:формат((к),встроку(з), (";"):байт()))
-- конец
-- 
var = 45;   
если var тогда 
  -- локал v = var; 
  печать(v);   
конец -- всё, var больше не имеет значения v
счетчик=10
пока счетчик>0 
	печать('счетчик', счетчик)
	счетчик=счетчик-1
конец