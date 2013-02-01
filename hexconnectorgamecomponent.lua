--[[

hexconnectorgamecomponent.lua
January 30th, 2013

]]

local color = require 'color'

local setmetatable, ipairs, math, love
	= setmetatable, ipairs, math, love
		
module(...)

local defaultFont = love.graphics.newFont(11)
local bigFont = love.graphics.newFont(24)
local hugeFont = love.graphics.newFont(100)

--
--  Creates a hex connector game component
--
function _M:new(board)		
	local o = { 
		_board = board,
		_xoffset = -300,
		_yoffset = -1000,
		_hexWideWidth = 50,
		_hexNarrowWidth = 50 * 0.75,
		_hexHeight = 40,		
		_drawingColor = nil,
		_roundTime = 20,
		_score = 0
	}
		
	self.__index = self
	o = setmetatable(o, self)	

	return o
end

function _M:drawHexagon(m, x, y)
	local m = m or 'fill'
	local w = self._hexWideWidth - 2
	local h = self._hexHeight - 2

	local xunit = w * 0.25
	local yunit = h * 0.5
	
	local x1 = x + xunit 
	local x3 = x + xunit * 3
	local x4 = x + xunit * 4
	local y1 = y + yunit
	local y2 = y + yunit * 2
	
	love.graphics.polygon(m, 
		x, y1, 
		x1, y, 
		x3, y, 
		x4, y1, 
		x3, y2, 
		x1, y2)
end

--
--  Draws the component
--
function _M:draw()
	love.graphics.setFont(defaultFont)
	love.graphics.setLineWidth(2)		
				
	local line_color
	
	for y = 5, 45 do
		for x = 5, 45 do
			local tile = self._board._map:tile(x,y)
			
			if not tile.disabled then				
				local sx = (self._hexNarrowWidth * x) + self._xoffset
				local sy = (self._hexHeight * (x * 0.5 + y)) + self._yoffset
				
				if tile.hilighted then 
					line_color = color.white
				else
					line_color = tile.color or color.grey				
				end				
				
				if tile.filled then
					love.graphics.setColor(tile.color)
					self:drawHexagon('fill', sx, sy)
				end
					
				love.graphics.setColor(line_color)
				self:drawHexagon('line', sx, sy)

				--[[
				love.graphics.setColor(0, 255, 0, 255)
				love.graphics.print(x .. ',' .. y, sx, sy)
				]]
			end					
		end
	end
	
	love.graphics.setFont(hugeFont)
	love.graphics.setColor(0,255,0,255)
	love.graphics.print(math.ceil(self._roundTime), 10, 10)
	
	love.graphics.setFont(bigFont)	
	love.graphics.print('Score: ' .. self._score, 500, 10)
						
	--[[
	love.graphics.print(mx .. ',' .. my, 0, 0)
	love.graphics.print(hx .. ',' .. hy, 0, 50)
	]]	
end

--
--  Does something for all of the tiles of one color
--
function _M:allTilesOfColor(c, fn)
	for tile in self._board._map:tiles() do
		if tile.color and 
		(tile.color[1] == c[1] 
		and tile.color[2] == c[2]
		and tile.color[3] == c[3]) then		
			fn(tile)
		end
	end
end

--
--  Updates the component
--
function _M:update(dt)
	self._roundTime = self._roundTime - dt
	if self._roundTime <= 0 then
		self._roundTime = 0
	end

	local mx, my = love.mouse.getPosition()	
	local hmx = mx - self._xoffset - 10
	local hmy = my - self._yoffset + 0
	
	local hx = math.floor(hmx / self._hexNarrowWidth)
	local hy = math.floor(hmy / self._hexHeight - hx * 0.5)
	
	local currentTile = self._board._map:tile(hx, hy)
	
	if currentTile and not currentTile.disabled and not currentTile.locked then
		if love.mouse.isDown('l') then						
			if not self._drawingColor and currentTile.color then
				self._drawingColor = currentTile.color
			end
		else
			self._drawingColor = nil
		end
					
		if previousTile then
			previousTile.hilighted = false
		end	
		currentTile.hilighted = true
		previousTile = currentTile			
				
		if self._drawingColor and not currentTile.color then
			currentTile.color = self._drawingColor
			currentTile.filled = true
			self._board:checkConnectors(
				function(c)
					self:allTilesOfColor(c.color, function(tile)
						tile.locked = true
						tile.color = { 50, 50, 50, 255 }				
					end)

					self._score = self._score + 50
					self._drawingColor = nil

					currentTile.hilighted = false
					previousTile.hilighted = false
					currentTile = nil
					previousTile = nil
				end, 
				function(c)
					self._score = -1000
					
					self:allTilesOfColor(c.color, function(tile)
						tile.locked = true
						tile.color = { tile.color[1], tile.color[2], tile.color[3], 64 }							
					end)
				end)
		end
	end	

end