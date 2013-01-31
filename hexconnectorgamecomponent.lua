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
		_drawingColor = nil
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

--[[
local xoff = -300
local yoff = -1000
local w = 50
local nw = w * 0.75
local h = 40
local drawingColor = nil
]]
			
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
	
	-- draw the status of the connectors			
	love.graphics.setFont(bigFont)
	local sx = 0
	local sy = 0
	for k, c in ipairs(self._board._connectors) do								
		love.graphics.setColor(c.color)
		if c.connected == 1 then
			love.graphics.print('CONNECTED', sx, sy)
		elseif c.connected == -1 then
			love.graphics.print('BLOCKED!', sx, sy)
		else
			love.graphics.print('NOT CONNECTED', sx, sy)
		end
		
		sy = sy + 30
	end	
						
	--[[
	love.graphics.print(mx .. ',' .. my, 0, 0)
	love.graphics.print(hx .. ',' .. hy, 0, 50)
	]]	
end

--
--  Updates the component
--
function _M:update(dt)
	local mx, my = love.mouse.getPosition()	
	local hmx = mx - self._xoffset - 10
	local hmy = my - self._yoffset + 0
	
	local hx = math.floor(hmx / self._hexNarrowWidth)
	local hy = math.floor(hmy / self._hexHeight - hx * 0.5)
	
	local currentTile = self._board._map:tile(hx, hy)
	
	if currentTile and not currentTile.disabled then
		if love.mouse.isDown('l') then						
			if not drawingColor and currentTile.color then
				drawingColor = currentTile.color
			end
		else
			drawingColor = nil
		end
		
		if drawingColor and not currentTile.color then
			currentTile.color = drawingColor
			currentTile.filled = true
			self._board:checkConnectors()
		end
		
		if previousTile then
			previousTile.hilighted = false
		end	
		currentTile.hilighted = true
		previousTile = currentTile
	end	
end