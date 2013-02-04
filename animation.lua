--[[
	animation.lua
	
	Created JUN-21-2012
]]

local Object = (require 'object').Object

module('objects')

Animation = Object{}

--
--  Animation constructor
--
function Animation:_clone(values)
	local o = Object._clone(self,values)
	
	o._delayModifier = 0
	
	o:reset()
	
	return o
end


--
--  Updates an animation
--
--  Outputs:
--		the new frame number if the frame should change
--
function Animation:update(dt)
	local d = self._definition

	self._currentDelay = self._currentDelay + dt			
	local actualDelay = d._delays[self._currentFrame] + self._delayModifier
	if self._currentDelay >= actualDelay then
		self._currentDelay = self._currentDelay - actualDelay
		self._currentFrame = self._currentFrame + self._frameDirection
						
		if self._currentFrame < 1 or self._currentFrame > #d._frames then
			self._currentLoop = self._currentLoop + 1
			if d._loopCount == -1 or self._currentLoop < d._loopCount then
				if d._loopType == 'loop' then
					self._currentFrame = 1
				elseif d._loopType == 'pingpong' then
					self._frameDirection = self._frameDirection * -1
					self._currentFrame = self._currentFrame + (self._frameDirection * 2)
				end						
			else
				self._currentFrame = self._currentFrame - self._frameDirection 
				self._frameDirection = 0
			
				if self.done_cb then
					self:done_cb()
				end
			end
		end
		
		if self.on_frame_change then
			self:on_frame_change()
		end
	end
end

--
--  Resets the animation
--
function Animation:reset()
	self._currentFrame = 1
	self._currentDelay = 0
	self._currentLoop = 0
	self._frameDirection = 1
end

--
--  Returns the name of this animation
--
function Animation:name()
	return self._name
end

--
--  Returns the current frame of the animation
--
function Animation:quadNumber()
	return self._definition._frames[self._currentFrame]
end

--
--  Returns the current offset of the animation
--
function Animation:offset()
	return self._definition._offsets[self._currentFrame]
end

--
--  Returns the collision boundary for the current animation
--
function Animation:boundary()
	return self._definition._boundaries[self._currentFrame]
end