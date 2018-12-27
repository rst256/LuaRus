
--
-- lua-CodeGen : <http://fperrad.github.com/lua-CodeGen>
--

local pairs = pairs
local type = type
local _G = _G
local table = require 'table'
local CodeGen = require 'CodeGen'

_ENV = nil
local m = {}

local template = CodeGen {
    TOP = [[
digraph {
    node [ shape = none ];

    ${nodes/_node()}

    ${edges/_edge()}
}
]],
    _node = [[
${name};
]],
    _edge = [[
${caller} -> ${callee};
]],
}
m.template = template

function m:to_dot ()
    local done = {}
    local nodes = {}
    local edges = {}

    local function parse (key)
        if not done[key] then
            done[key] = true
            local tmpl = self[key]
            if type(tmpl) == 'string' then
                table.insert(nodes, { name = key })
                for capt in tmpl:gmatch "(%$%b{})" do
                    local capt1, pos = capt:match("^%${([%a_][%w%._]*)()", 1)
                    if capt1 then
                        if capt:match("^%(%)", pos) then
                            table.insert(edges, { caller = key, callee = capt1 })
                            parse(capt1)
                        else
                            local capt2, capt3 = capt:match("^?([%a_][%w_]*)%(%)!([%a_][%w_]*)%(%)", pos)
                            if capt2 and capt3 then
                                table.insert(edges, { caller = key, callee = capt2 })
                                table.insert(edges, { caller = key, callee = capt3 })
                                parse(capt2)
                                parse(capt3)
                            else
                                local capt2 = capt:match("^[?/]([%a_][%w_]*)%(%)", pos)
                                if capt2 then
                                    table.insert(edges, { caller = key, callee = capt2 })
                                     parse(capt2)
                                end
                            end
                        end
                    end
                end
            end
        end
    end  -- parse

    for k in pairs(self[1]) do
        parse(k)
    end
    template.nodes = nodes
    template.edges = edges
    local dot = template 'TOP'
    return dot
end

m._NAME = ...
return m
--
-- Copyright (c) 2010-2011 Francois Perrad
--
-- This library is licensed under the terms of the MIT/X11 license,
-- like Lua itself.
--
