-- @file        validation.lua
-- @author      Théo Brigitte <theo.brigitte@gmail.com>
-- @contributor Henrique Silva <hensansi@gmail.com>
-- @date        Thu May 28 16:05:15 2015
--
-- @brief       Lua schema validation library.
--
-- Validation is achieved by matching data against a schema.
--
-- A schema is a representation of the expected structure of the data. It is
-- a combination of what we call "validators".
-- Validators are clojures which build accurante validation function for each
-- element of the schema.
-- Meta-validators allow to extend the logic of the schema by providing an
-- additional logic layer around validators.
--  e.g. optional()
--

-- Import from global environment.
local ms = require'meta-schema'

function ms.__index:create(parent)
	print(self, parent)
end

return ms
