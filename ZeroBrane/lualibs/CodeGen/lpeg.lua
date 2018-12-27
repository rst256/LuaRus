
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
local lpeg = require 'lpeg'

_ENV = nil
local m = {}

local function gsub (s, patt, repl)
    local p = lpeg.Cs((patt / repl + 1)^0)
    return p:match(s)
end

local function split (s, sep, func)
    local elem = lpeg.C((1 - sep)^0) / func
    local p = elem * (sep * elem)^0
    p:match(s)
end

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

local digit = lpeg.R'09'
local escape_digit = lpeg.P[[\]]*lpeg.C(digit * digit^-2)
local escape_special = lpeg.P[[\]]*lpeg.C(lpeg.S[[abfnrtv\"']])

local function unescape(str)
    str = gsub(str, escape_digit, function (s)
                                      return char(tonumber(s) % 256)
                                  end)
    return gsub(str, escape_special, special)
end

local dot = lpeg.P'.'
local space = lpeg.S" \t"
local newline = lpeg.P"\n"
local newline_anywhere = lpeg.P{ newline + 1 * lpeg.V(1) }
local only_space = space^0 * -1
local newline_end = newline * -1
local indent_needed = newline * -newline

local vname_capture = lpeg.P'${' * lpeg.C(lpeg.R('AZ', 'az', '__') * lpeg.R('09', 'AZ', 'az', '__', '..')^0) * lpeg.Cp()
local separator_simple_quote_capture = lpeg.P"'" * lpeg.C((lpeg.P(1) - "'")^0) * lpeg.P"'"
local separator_double_quote_capture = lpeg.P'"' * lpeg.C((lpeg.P(1) - '"')^0) * lpeg.P'"'
local separator_capture = lpeg.P';' * space^1 * lpeg.P'separator' * space^0 * lpeg.P'=' * space^0 *
    (separator_simple_quote_capture + separator_double_quote_capture) * space^0 * lpeg.Cp()
local identifier_capture = lpeg.C(lpeg.R('AZ', 'az', '__') * lpeg.R('09', 'AZ', 'az', '__')^0)
local format_capture = lpeg.P';' * space^1 * lpeg.P'format' * space^0 * lpeg.P'=' * space^0 *
    identifier_capture * space^0 * lpeg.Cp()
local data_end = lpeg.P'}'
local include_end = lpeg.P'()}'
local if_capture = lpeg.P'?' * identifier_capture * lpeg.P'()}'
local if_else_capture = lpeg.P'?' * identifier_capture * lpeg.P'()!' * identifier_capture * lpeg.P'()}'
local map_capture = lpeg.P'/' * identifier_capture * lpeg.P'()' * lpeg.Cp()
local map_end = lpeg.P'}'

local subst = lpeg.P'$' * lpeg.P{ '{' * ((1 - lpeg.S'{}') + lpeg.V(1))^0 * '}' }
local indent_capture = lpeg.C(space^0) * subst * -1

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
            local t = self
            split(vname, dot, function (w)
                if type(t) == 'table' then
                    t = t[w]
                else
                    add_message(vname, " is invalid")
                    t = nil
                end
            end)
            return t
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

                local capt1, pos = vname_capture:match(capt, 1)
                if not capt1 then
                    add_message(capt, " does not match")
                    return capt
                end
                local sep, pos_sep = separator_capture:match(capt, pos)
                if sep then
                    sep = unescape(sep)
                end
                local fmt, pos_fmt = format_capture:match(capt, pos_sep or pos)
                if data_end:match(capt, pos_fmt or pos_sep or pos) then
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
                if include_end:match(capt, pos) then
                    return apply(self, capt1)
                end
                local capt2 = if_capture:match(capt, pos)
                if capt2 then
                    if get_value(capt1) then
                        return apply(self, capt2)
                    else
                        return ''
                    end
                end
                local capt2, capt3 = if_else_capture:match(capt, pos)
                if capt2 and capt3 then
                    if get_value(capt1) then
                        return apply(self, capt2)
                    else
                        return apply(self, capt3)
                    end
                end
                local capt2, pos = map_capture:match(capt, pos)
                if capt2 then
                    local sep, pos_sep = separator_capture:match(capt, pos)
                    if sep then
                        sep = unescape(sep)
                    end
                    if map_end:match(capt, pos_sep or pos) then
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

            local indent = indent_capture:match(line)
            local result = gsub(line, subst, get_repl)
            if indent then
                result = gsub(result, newline_end, '')
                if indent ~= '' then
                    result = gsub(result, indent_needed, "\n" .. indent)
                end
            end
            return result
        end -- interpolate_line

        if newline_anywhere:match(template) then
            local results = {}
            split(template, newline, function (line)
                local result = interpolate_line(line)
                if result == line or not only_space:match(result) then
                    results[#results+1] = result
                end
                lineno = lineno + 1
            end)
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

_G.package.loaded['CodeGen'] = m

m._NAME = 'CodeGen'
m._VERSION = "0.2.3"
m._DESCRIPTION = "lua-CodeGen : a template engine"
m._COPYRIGHT = "Copyright (c) 2010-2011 Francois Perrad"
return m
--
-- This library is licensed under the terms of the MIT/X11 license,
-- like Lua itself.
--
