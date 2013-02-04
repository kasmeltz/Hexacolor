--[[
	
spell.lua
February 4th, 2013

]]

local inputManager = require 'gameInputManager'

local Object = (require 'object').Object

local love = love

module('objects')

Spell = Object{}

--
--  Spell constructor
--
function Spell:_clone(values)	
	local o = Object._clone(self, values)
			
	o.SPELL = true
	o._casting = false	
	o._manaRequired = 0

	return o
end

--
--  Base spell update
--
function Spell:update(dt)
	if inputManager.keyReleased[self._shortcutKey] then
		self._casting = true
	end
	
	if inputManager.mouseReleased['l'] then
		if self.onMouseRelease then
			self:onMouseRelease('l')
		end
	end
end

