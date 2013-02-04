--[[
	
pathedactor.lua
February 4th, 2013

]]

local Object = (require 'object').Object

require 'actor'

local table, math
	= table, math
	
module('objects')

PathedActor = Object{}

--
--  PathedActor constructor
--
function PathedActor:_clone(values)	
	local o = table.merge(Actor(values), Object._clone(self,values))
			
	o.PATHEDACTOR = true
	
	o._currentTile = 1
	o._nextTile = 2
	o._targetChanged = true	
	
	o._position[1] = o._path[1].screenX + o._tileOffset[1]
	o._position[2] = o._path[1].screenY + o._tileOffset[2]	

	return o
end

--
--  PathedActor target difference
--
function PathedActor:targetDifference(tile)
	local targetX = tile.screenX + self._tileOffset[1]
	local targetY = tile.screenY + self._tileOffset[2]	
	dx = targetX - self._position[1]
	dy = targetY - self._position[2]			
	dl = math.sqrt(dx * dx + dy * dy)
	
	return dx, dy, dl
end
	
--
--  PathedActor update function
--
function PathedActor:update(dt)	
	local targetTile = self._path[self._nextTile]
	local dx, dy, dl
	if targetTile then
		dx, dy, dl = self:targetDifference(targetTile)
	else
		self._targetChanged = true
	end
	
	if self._targetChanged then		
		self._velocity[1] = 0
		self._velocity[2] = 0
		if dx and dy and dl then								
			self._velocity[1] = self._speed * dx / dl
			self._velocity[2] = self._speed* dy / dl
		end
		self._targetChanged = false
	end		
	
	if self._nextTile <= #self._path then		
		if dl and dl < 1 then
			self._currentTile = self._currentTile + 1
			self._nextTile = self._nextTile + 1
			self._position[1] = self._path[self._currentTile].screenX + self._tileOffset[1]
			self._position[2] = self._path[self._currentTile].screenY + self._tileOffset[2]
	
			self._targetChanged = true
		end
	end		
	
	if self._velocity[1] > 5 then
		self:direction('right')
	elseif self._velocity[1] < -5 then
		self:direction('left')
	elseif self._velocity[2] > 0 then
		self:direction('down')
	elseif self._velocity[2] < 0 then
		self:direction('up')
	end		
	
	if self._velocity[1] == 0 and self._velocity[2] == 0 then
		self:animation('stand')
	else
		self:animation('walk')
	end
	
	Actor.update(self, dt)	
end
