--[[

object.lua
January 17th, 2013	

The object model has been replicated from an article in Lua Programming Gems
(p. 129). This is a simple object model that provides inheritance and member
function and field semantics.
  
--]]

local table        = require('table_ext')
local setmetatable = setmetatable

module(...)

Object = {
	_init = {},

	_clone = function (self, values)
		local object = table.merge(self, table.rearrange(values,self._init))
		return setmetatable(object, object)
	 end,
	__call =  function (...)
		return (...)._clone(...)
	 end
}

setmetatable(Object,Object)