--[[
	
actor.lua
January 17th, 2013

]]

local Object = (require 'object').Object

require 'drawable'
require 'collidable'

local table
	= table
	
module('objects')

Actor = Object{}

--
--  Actors support the following Events:
--
--		on_begin_X() - will be called when the actor begins an action
--		on_end_X() - will be called when the actor begins an action
--

--
--  Actor constructor
--
function Actor:_clone(values)	
	local collidable = values._collidable or Collidable(values)
	
	local o = table.merge(
		table.merge(collidable, Drawable(values)),
		Object._clone(self,values))
			
	o.ACTOR = true
  	o._lastPosUpdate = values._lastPosUpdate or { 0, 0 }	
	o._velocity = values._velocity or { 0, 0 }	
	o._currentAction = values._currentAction or nil	

	return o
end

--
--  Set or get the velocity 
--
function Actor:velocity(x, y)
	if not x then
		return self._velocity
	end
	
	self._velocity[1] = x
	self._velocity[2] = y
end

--
--  Update function
--
function Actor:update(dt)
	self._latestDt = dt
	
	self._lastPosUpdate[1] = (dt * self._velocity[1])
	self._lastPosUpdate[2] = (dt * self._velocity[2])
	
	self._position[1] = self._position[1] + self._lastPosUpdate[1]		
	self._position[2] = self._position[2] + self._lastPosUpdate[2]
	
	Drawable.update(self, dt)	
	self:calculateBoundary()
end

--
--  Sets or gets the actors name
--
function Actor:name(n)
	if not n then return self._name end
	self._name = n
end

--
--  Called when a collidable collides with
--  another object
--
function Actor:collide(other)	
	-- only adjust positions for blocking items
	if not other._nonBlocking then
		if self._lastPosUpdate[1] ~= 0 or self._lastPosUpdate[2] ~= 0 then
			-- check if reversing the last update moves the
			-- actor farther away from the other object
			local xdiff = other._position[1] - self._position[1]
			local ydiff = other._position[2] - self._position[2]			
			local currentDist = xdiff * xdiff + ydiff * ydiff

			local xdiff = other._position[1] - 
				(self._position[1] - self._lastPosUpdate[1])
			local ydiff = other._position[2] - 
				(self._position[2] - self._lastPosUpdate[2])
			local possibleDist = xdiff * xdiff + ydiff * ydiff

			if currentDist < possibleDist then
				self._position[1] = self._position[1] - self._lastPosUpdate[1]		
				self._position[2] = self._position[2] - self._lastPosUpdate[2]
				self._lastPosUpdate[1] = 0
				self._lastPosUpdate[2] = 0
			end
			
			self:calculateBoundary()		
		end
	end
	
	Collidable.collide(self, other)
end

--
--  Do an action
-- 
function Actor:action(name, cancel)
	if not name then return self._currentAction end
	
	-- can only do an action when not doing an action
	if self._currentAction and not cancel then
		return 
	end
	
	-- an action is cancelled if 
	-- on_begin_X returns false	
	local retval	
	if self['on_begin_' .. name] then
		retval = self['on_begin_' .. name](self)
	end		
	if retval == false then return end
	
	-- set the current action
	self._currentAction = name
						
	-- save old animation
	local currentAnim
	if self._currentAnimation then
		currentAnim = self._currentAnimation:name()
	end
	-- switch to the new animation
	self:animation(name, true)
	-- set the callback for when the animation ends
	self._currentAnimation.done_cb = function()
		self._currentAnimation.done_cb = nil			
		self._currentAction = nil
	
		if currentAnim then
			self:animation(currentAnim, true)
		end
				
		if self['on_end_' .. name] then
			self['on_end_' .. name](self)
		end
	end	
end