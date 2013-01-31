--[[

hexconnectorboard.lua
January 30th, 2013

]]

local hexmap = require 'hexmap'

local setmetatable, ipairs, math
	= setmetatable, ipairs, math
		
module(...)

--
--  Creates a hex connector game
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
--  Adds a new connector to the game
--
function _M:addConnector(x1, y1, x2, y2, color)
	local connector = {
		x1 = x1, y1 = y1, x2 = x2, y2 = y2, 
		connected = false,
		color = { color[1], color[2], color[3], color[4] }
	}
	self._connectors[#self._connectors + 1] = connector	
	
	local tile = self._map:tile(x1, y1)
	tile.color = color
	tile.filled = true
	tile = self._map:tile(x2, y2)
	tile.color = color
	tile.filled = true		
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
	
	m:enableRadialTiles(self._centerX, self._centerY, self._radius)
		
	self._map = m
	self._connectors = {}
end

--
--  Checks the connectors
--
function _M:checkConnectors()
	for _, c in ipairs(self._connectors) do	
		-- check if the connectors have been connected
		if not c.connected then
			local result = self._map:pathExists(c.x1, c.y1, c.x2, c.y2,
				function(a, b)
					return 	
						not b.disabled and
						a.color and b.color and
						(a.color[1] == b.color[1]
						and
						a.color[2] == b.color[2]
						and
						a.color[3] == b.color[3])
				end)
			if result then
				c.connected = 1
			end
		end
		
		-- check if it is even possible to still connect these connectors
		if not c.connected then
			local firstColor = self._map:tile(c.x1, c.y1).color
			local result = self._map:pathExists(c.x1, c.y1, c.x2, c.y2,
				function(a, b)
					return 
						not b.disabled and 
						(not b.color or 
						(b.color[1] == firstColor[1]
						and
						b.color[2] == firstColor[2]
						and
						b.color[3] == firstColor[3]))
				end)
			if not result then
				c.connected = -1
			end
		end		
	end
end