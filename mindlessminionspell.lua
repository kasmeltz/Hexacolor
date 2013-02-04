--[[
	
mindlessminionspell.lua
February 4th, 2013

]]

require 'pathedactor'
require 'spell'

local Object = (require 'object').Object

local spriteSheetManager = require 'spriteSheetManager'

local love = love

local table, ipairs, math
	= table, ipairs, math
	
module('objects')

MindlessMinionSpell = Object{}

--
--  TemporaryFloorSpell constructor
--
function MindlessMinionSpell:_clone(values)	

	local o = table.merge(Spell(values), 
		Object._clone(self,values))
			
	o.MINDLESSMINIONSPELL = true
	o._manaRequired = 50
	o._path = {}

	return o
end

--
--  Calculates the path from the first tile to the second tile
--
function MindlessMinionSpell:calculatePath(firstTile, secondTile)
	if not firstTile or not secondTile then return end
	for k, _ in ipairs(self._path) do
		self._path[k] = nil
	end	
	
	local currentTile = firstTile
	local tries = 0
	repeat
		self._path[#self._path + 1] = currentTile
		
		local tx, ty = currentTile.tileX, currentTile.tileY

		if tx < secondTile.tileX then 
			if ty == secondTile.tileY then
				tx = tx + 1
			elseif ty > secondTile.tileY then
				tx = tx + 1
				ty = ty - 1
			elseif ty < secondTile.tileY then
				ty = ty + 1
			end
		elseif tx > secondTile.tileX then
			if ty == secondTile.tileY then
				tx = tx - 1
			elseif ty < secondTile.tileY then
				tx = tx - 1
				ty = ty + 1
			elseif ty > secondTile.tileY then
				ty = ty - 1
			end
		elseif tx == secondTile.tileX then 
			if ty < secondTile.tileY then
				ty = ty + 1
			elseif ty > secondTile.tileY then
				ty = ty - 1
			end
		end
		tries = tries + 1
		currentTile = self._hgc._board._map:tile(tx,ty)		
	until currentTile == secondTile or tries > 100

	self._path[#self._path + 1] = currentTile
end

--
--  Update function for the Mindless Minion spell
--
function MindlessMinionSpell:update(dt)
	Spell.update(self, dt)	

	if not self._casting then return end		
	
	for _, v in ipairs(self._path) do
		v.hilightColor = nil
	end
	
	local tile = self._hgc:selectedTile()
	if not tile then return end

	if self._firstTile then
		self:calculatePath(self._firstTile, tile)
	else
		self:calculatePath(tile, tile)
	end
	
	self:tileHighlighting(self._path, { 0, 255, 0, 128 })
end

--
--  Selects the first tile for the Mindless Minion spell
--
function MindlessMinionSpell:selectFirstTile(tile)
	self._firstTile = tile	
end

--
--  Removes tile highlting for the current path
--
function MindlessMinionSpell:tileHighlighting(path, color)
	for _, tile in ipairs(path) do
		tile.hilightColor = color
	end
end

--
--  Selects the second tile for the Mindless Minion spell
--
function MindlessMinionSpell:selectSecondTile(tile)	
	if self._hgc._mana < self._manaRequired then return end	
	self._hgc._mana = self._hgc._mana - self._manaRequired
	self._casting = false
	self._firstTile = nil	
	
	self:tileHighlighting(self._path, nil)
	
	local a = PathedActor{ 
		_speed = 20,
		_path = table.clone(self._path),
		_spriteSheet = spriteSheetManager.sheet('male_body_light'),
		_tileOffset = { self._hgc._hexWideWidth / 2, self._hgc._hexHeight * 0.75 }
	}
	
	a.update = function(a, dt)
		local hx, hy = self._hgc:screenToHex(a._position[1], a._position[2])
		local tile = self._hgc._board._map:tile(hx, hy)
		if tile then
			if not tile.filled then 
				self._scene:removeComponent(a) 	
			end			
			if tile.goal then	
				self._hgc._score = self._hgc._score + 1000
				self._scene:removeComponent(a)				
			end
		end
		
		PathedActor.update(a, dt)		
	end	
	a:update(0)			
	
	self._scene:addComponent(a)	
end

--
--  Mouse button press handler for the 
--	Mindless Minion spell
--
function MindlessMinionSpell:onMouseRelease(b)
	if not self._casting then return end		
	local tile = self._hgc:selectedTile()
	if not tile then return end		
	
	if not self._firstTile then
		self:selectFirstTile(tile)
	else
		self:selectSecondTile(tile)
	end	
end