--[[
	
temporaryfloorspell.lua
February 4th, 2013

]]

require 'spell'

local Object = (require 'object').Object

local love = love

local table
	= table
	
module('objects')

TemporaryFloorSpell = Object{}

--
--  TemporaryFloorSpell constructor
--
function TemporaryFloorSpell:_clone(values)	

	local o = table.merge(Spell(values), 
		Object._clone(self,values))
			
	o.TEMPORARYFLOORSPELL = true
	o._manaRequired = 100

	return o
end

--
--  Update function for the Temporary Floor Spell
--
function TemporaryFloorSpell:update(dt)
	Spell.update(self, dt)	

	if not self._casting then return end		
	
	if self._previousTile then 
		self._previousTile.hilightColor = nil
	end		
			
	local tile = self._hgc:selectedTile()
	if not tile then return end
			
	if tile.filled then
		tile.hilightColor = { 255, 0, 0, 128 }
	else
		tile.hilightColor = { 0, 255, 0, 128 }
	end
	
	self._previousTile = tile
end

--
--  Mouse button press handler for the 
--	temporary floor spell
--
function TemporaryFloorSpell:onMouseRelease(b)
	if not self._casting then return end		
	local tile = self._hgc:selectedTile()
	if not tile then return end		
	if tile.filled then return end
	
	tile.hilightColor = nil
	
	if self._hgc._mana < self._manaRequired then return end	
	self._hgc._mana = self._hgc._mana - self._manaRequired
	self._casting = false
	
	local oldTileFilled = tile.filled
	local oldTileColor = tile.color
	
	tile.filled = true
	tile.color = { 255, 0, 255, 255 }
	
	local a = { _floorTime = 3 }
	a.update = function(this, dt)	
		a._floorTime = a._floorTime - dt
		if a._floorTime <= 0 then
			tile.filled = oldTileFilled
			tile.color = oldTileColor
			a._scene:removeComponent(a)
		end
	end		
	
	self._scene:addComponent(a)	
end

