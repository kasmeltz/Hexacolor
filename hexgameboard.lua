--[[

hexgameboard.lua
January 30th, 2013

]]

local hexmap = require 'hexmap'

local setmetatable, ipairs, math
	= setmetatable, ipairs, math
		
module(...)

--
--  Creates a hex game board
--
function _M:new(cx, cy, r)		
	local o = { 
		_centerX = cx,
		_centerY = cy,
		_radius = r,
	}
		
	self.__index = self
	o = setmetatable(o, self)	

	o:reset()		
	
	return o
end

--
--  Reset the game
--
function _M:reset()
	local m = hexmap:new(100, 100)
	
	for tile in m:tiles() do
		tile.filled = false
		tile.disabled = true
	end
	
	m:radialTiles(self._centerX, self._centerY, self._radius,
		function(tile)
			tile.disabled = false
		end)
		
	self._map = m
	self._games = {}
end