--[[

gameScene.lua
January 9th, 2013

]]
local setmetatable, pairs
	= setmetatable, pairs
		
module(...)

--
--  Creates a game scene
--
function _M:new()	
	local o = { 
		components = {}
	}	
	
	self.__index = self
	return setmetatable(o, self)	
end

--
--  Draws the game scene
--
function _M:draw()
	for _, c in pairs(self.components) do
		if c.draw then
			c:draw()
		end
	end
end

--
--  Updates the game scene
--
function _M:update(dt)
	for _, c in pairs(self.components) do
		if c.update then
			c:update(dt)	
		end
	end
end

--
--  Adds a component
--
function _M:addComponent(c)
	self.components[c] = c
end

--
--  Removes a component
--
function _M:removeComponent(c)
	self.components[c] = nil
end

