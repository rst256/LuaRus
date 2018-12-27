
--
-- lua-CodeGen : <http://fperrad.github.com/lua-CodeGen>
--

local setmetatable = setmetatable
local tonumber = tonumber
local tostring = tostring
local type = type
local char = require 'string'.char
local tconcat = require 'table'.concat
local _G = _G

_ENV = nil
local m = {}

local function render (val, sep, formatter)
    formatter = formatter or tostring
    if val == nil then
        return ''
    end
    if type(val) == 'table' then
        local t = {}
        for i = 1, #val do
            t[i] = formatter(val[i])
        end
        return tconcat(t, sep)
    else
        return formatter(val)
    end
end

local special = {
    ['a']  = "\a",
    ['b']  = "\b",
    ['f']  = "\f",
    ['n']  = "\n",
    ['r']  = "\r",
    ['t']  = "\t",
    ['v']  = "\v",
    ['\\'] = '\\',
    ['"']  = '"',
    ["'"]  = "'",
}

local function unescape(str)
    str = str:gsub([[\(%d%d?%d?)]], function (s)
                                        return char(tonumber(s) % 256)
                                    end)
    return str:gsub([[\([abfnrtv\"'])]], special)
end

local new
local function eval (self, name)
    local cyclic = {}
    local msg = {}

    local function interpolate (self, template, tname)
        if type(template) ~= 'string' then
            return nil
        end
        local lineno = 1

        local function add_message (...)
            msg[#msg+1] = tname .. ':' .. lineno .. ': ' .. tconcat{...}
        end  -- add_message

        local function get_value (vname)
            local i = 1
            local t = self
            for w in vname:gmatch "(%w+)%." do
                i = i + w:len() + 1
                t = t[w]
                if type(t) ~= 'table' then
                    add_message(vname, " is invalid")
                    return nil
                end
            end
            return t[vname:sub(i)]
        end  -- get_value

        local function interpolate_line (line)
            local function get_repl (capt)
                local function apply (self, tmpl)
                    if cyclic[tmpl] then
                        add_message("cyclic call of ", tmpl)
                        return capt
                    end
                    cyclic[tmpl] = true
                    local result = interpolate(self, self[tmpl], tmpl)
                    cyclic[tmpl] = nil
                    if result == nil then
                        add_message(tmpl, " is not a template")
                        return capt
                    end
                    return result
                end  -- apply

                local capt1, pos = capt:match("^%${([%a_][%w%._]*)()", 1)
                if not capt1 then
                    add_message(capt, " does not match")
                    return capt
                end
                local sep, pos_sep = capt:match("^;%s+separator%s*=%s*'([^']+)'%s*()", pos)
                if not sep then
                      sep, pos_sep = capt:match("^;%s+separator%s*=%s*\"([^\"]+)\"%s*()", pos)
                end
                if sep then
                    sep = unescape(sep)
                end
                local fmt, pos_fmt = capt:match("^;%s+format%s*=%s*([%a_][%w_]*)%s*()", pos_sep or pos)
                if capt:match("^}", pos_fmt or pos_sep or pos) then
                    if fmt then
                        local formatter = self[fmt]
                        if type(formatter) ~= 'function' then
                            add_message(fmt, " is not a formatter")
                            return capt
                        end
                        return render(get_value(capt1), sep, formatter)
                    else
                        return render(get_value(capt1), sep)
                    end
                end
                if capt:match("^%(%)}", pos) then
                    return apply(self, capt1)
                end
                local capt2 = capt:match("^?([%a_][%w_]*)%(%)}", pos)
                if capt2 then
                    if get_value(capt1) then
                        return apply(self, capt2)
                    else
                        return ''
                    end
                end
                local capt2, capt3 = capt:match("^?([%a_][%w_]*)%(%)!([%a_][%w_]*)%(%)}", pos)
                if capt2 and capt3 then
                    if get_value(capt1) then
                        return apply(self, capt2)
                    else
                        return apply(self, capt3)
                    end
                end
                local capt2, pos = capt:match("^/([%a_][%w_]*)%(%)()", pos)
                if capt2 then
                    local sep, pos_sep = capt:match("^;%s+separator%s*=%s*'([^']+)'%s*()", pos)
                    if not sep then
                          sep, pos_sep = capt:match("^;%s+separator%s*=%s*\"([^\"]+)\"%s*()", pos)
                    end
                    if sep then
                        sep = unescape(sep)
                    end
                    if capt:match("^}", pos_sep or pos) then
                        local array = get_value(capt1)
                        if array == nil then
                            return ''
                        end
                        if type(array) ~= 'table' then
                            add_message(capt1, " is not a table")
                            return capt
                        end
                        local results = {}
                        for i = 1, #array do
                            local item = array[i]
                            if type(item) ~= 'table' then
                                item = { it = item }
                            end
                            local result = apply(new(item, self), capt2)
                            results[#results+1] = result
                            if result == capt then
                                break
                            end
                        end
                        return tconcat(results, sep)
                    end
                end
                add_message(capt, " does not match")
                return capt
            end  -- get_repl

            local indent = line:match "^(%s*)%$%b{}$"
            local result = line:gsub("(%$%b{})", get_repl)
            if indent == '' then
                result = result:gsub("\n$", '')
            elseif indent then
                result = result:gsub("\n", "\n" .. indent)
                result = result:gsub("^" .. indent .. "\n", "\n")
                repeat
                    local nb
                    result, nb = result:gsub("\n" .. indent .. "\n", "\n\n")
                until nb == 0
                result = result:gsub("\n" .. indent .. "$", '')
            end
            return result
        end -- interpolate_line

        if template:find "\n" then
            local results = {}
            for line in template:gmatch "([^\n]*)\n?" do
                local result = interpolate_line(line)
                if result == line or not result:match'^%s*$' then
                    results[#results+1] = result
                end
                lineno = lineno + 1
            end
            return tconcat(results, "\n")
        else
            return interpolate_line(template)
        end
    end  -- interpolate

    local val = self[name]
    if type(val) == 'string' then
        return interpolate(self, val, name),
               (#msg > 0 and tconcat(msg, "\n")) or nil
    else
        return render(val)
    end
end

function new (env, ...)
    local obj = { env or {}, ... }
    setmetatable(obj, {
        __tostring = function () return m._NAME end,
        __call  = function (...) return eval(...) end,
        __index = function (t, k)
                      for i = 1, #t do
                          local v = t[i][k]
                          if v ~= nil then
                              return v
                          end
                      end
                  end,
    })
    return obj
end
m.new = new

setmetatable(m, {
    __call = function (func, ...) return new(...) end
})

m._NAME = ...
m._VERSION = "0.3.0"
m._DESCRIPTION = "lua-CodeGen : a template engine"
m._COPYRIGHT = "Copyright (c) 2010-2012 Francois Perrad"
return m
--
-- This library is licensed under the terms of the MIT/X11 license,
-- like Lua itself.
--
