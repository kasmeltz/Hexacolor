--[[
	
drawable.lua
January 17th, 2013

]]
local love = love

require 'animation'

local Object = (require 'object').Object

local pairs, math
	= pairs, math
	
module('objects')

Drawable = Object{}

--
--  Drawable constructor
--
function Drawable:_clone(values)
	local o = Object._clone(self,values)
	
	o.DRAWABLE = true
	o._screenPos = values._screenPos or { 0, 0 }
	o._position = values._position or { 0, 0 }	
	o._direction = values._direction or 'right'
	o._rotation = 0
	
	o:initializeAnimations()
	
	return o
end

--
--  Initializes the animations for this sprite
--
function Drawable:initializeAnimations()
	self._animations = {}
	
	for k, v in pairs(self._spriteSheet._animations) do
		local a = Animation{ _definition = v, _name = k }
		self._animations[k] = a		
	end
end

--
--  Sets or gets the current direction
--  
function Drawable:direction(d)
	if not d then return self._direction end
	
	if self._direction ~= d then
		self._changeDirection = true
	end
	
	self._direction = d
end

--
--  Sets or gets the current animation
--
--  Inputs:
--		a - an animation index or nil
--		r - true if the animation should be reset
--
function Drawable:animation(a, r)
	if not a then 
		return self._currentAnimation
	end
	
	-- switch to the new animation
	if self._animations[a] then
		self._currentAnimation = self._animations[a]
	else
		self._currentAnimation = self._animations[a .. self._direction]
	end				
	
	if r then
		self._currentAnimation:reset()
	end	
end

--
--  Draw the drawable
--
function Drawable:draw(camera, drawTable)
	local a = self._currentAnimation		
	local of = a:offset()
	
	self._screenPos[1] = 
		math.floor((self._position[1] * camera._zoomX) - camera._cwzx)
	self._screenPos[2] = 
		math.floor((self._position[2] * camera._zoomY) - camera._cwzy)
	
	love.graphics
		.drawq(
			self._spriteSheet._image, 
			self._spriteSheet._quads[a:quadNumber()], 
			self._screenPos[1], self._screenPos[2], 
			self._rotation, camera._zoomX, camera._zoomY,
			of[1], of[2]			
		)			
end

--
--  Set or get the position
--
function Drawable:position(x, y)
	if not x then
		return self._position
	end
		
	self._position[1] = x
	self._position[2] = y
end

--
--  Get the distance from another drawable
--
function Drawable:distanceFrom(other)
	local x = self._position[1] - other._position[1]
	local y = self._position[2] - other._position[2]
	return math.sqrt(x*x+y*y)
end


--
--  Set or get the screen position
--
function Drawable:screenPos(x, y)
	if not x then
		return self._screenPos
	end
		
	self._screenPos[1] = x
	self._screenPos[2] = y
end


-- 
--  Updates the Drawable
--
function Drawable:update(dt)
	-- updates the draw order
	self._drawOrder = self._position[2] + self._currentAnimation:offset()[2] - (self._position[1] * 1e-14)
	
	-- updates the animation
	if self._currentAnimation then	
		if self._synchronizer then
			self._currentAnimation._currentFrame = 
				self._synchronizer._currentAnimation._currentFrame
		else	
			self._currentAnimation:update(dt)
		end
	end
end