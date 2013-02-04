--[[

hexgamecomponent.lua
January 30th, 2013

]]

require 'actor'

local Objects = objects

local spriteSheetManager = require 'spriteSheetManager'
local color = require 'color'

local love = love

local setmetatable, ipairs, math, tostring
	= setmetatable, ipairs, math, tostring
		
module(...)

local defaultFont = love.graphics.newFont(11)
local bigFont = love.graphics.newFont(24)
local hugeFont = love.graphics.newFont(100)

--
--  Creates a hex game game component
--
function _M:new(board)		
	local o = { 
		_board = board,		
		_xoffset = 0,
		_yoffset = 0,	
		_maxMana = 200,
		_mana = 200,
		_manaRegenRate = 1,
		_drawingColor = nil,
		_roundTime = 60,
		_currentSpell = nil,
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
--  Sets the scale of the hexagons
--
function _M:hexagonScale(width, height)
	self._hexWideWidth = width
	self._hexHeight = height
	self._hexNarrowWidth = self._hexWideWidth * 0.75
	
	for tile in self._board._map:tiles() do
		local x = tile.tileX
		local y = tile.tileY
		tile.worldX = (self._hexNarrowWidth * x)
		tile.worldY = (self._hexHeight * (x * 0.5 + y))
	end
end

--
--  Sets the mapping from hex coordinates to world coordinates
--
function _M:setHexScreenMapping(x,y, sx, sy)
	local tile = self._board._map:tile(x, y)
	self._xoffset = sx - tile.worldX
	self._yoffset = sy - tile.worldY
	
	for tile in self._board._map:tiles() do
		tile.screenX = tile.worldX + self._xoffset
		tile.screenY = tile.worldY + self._yoffset
	end
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
				local sx = tile.screenX
				local sy = tile.screenY
				
				if tile.hilighted then 
					line_color = color.white
				else
					line_color = color.grey				
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
	love.graphics.print('Score: ' .. math.floor(self._score), 500, 10)
	love.graphics.print('Mana: ' .. math.floor(self._mana), 500, 50)
				
	love.graphics.setColor(255,255,255,255)
	
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
--  Converts screen coordinates to hex coordinates
--
function _M:screenToHex(sx, sy)
	local hmx = sx - self._xoffset - 10
	local hmy = sy - self._yoffset + 0
	local hx = math.floor(hmx / self._hexNarrowWidth)
	return hx, 
			math.floor(hmy / self._hexHeight - hx * 0.5)
end


--
--  Casts the create temporary floor spell
--
function _M:castCreateTemporaryFloorSpell(selectedTile)
	if self._mana < 100 then return end	
	self._mana = self._mana - 100
	
	local oldTileFilled = selectedTile.filled
	local oldTileColor = selectedTile.color
	
	selectedTile.filled = true
	selectedTile.color = { 255, 0, 255, 255 }
	
	local a = { _floorTime = 3 }
	a.update = function(this, dt)	
		a._floorTime = a._floorTime - dt
		if a._floorTime <= 0 then
			selectedTile.filled = oldTileFilled
			selectedTile.color = oldTileColor
			a._scene:removeComponent(a)
		end
	end		
	
	self._scene:addComponent(a)
end

--
--  Casts the create mindless minion spell
--
function _M:castCreateMindlessMinionSpell(selectedTile)
	if self._mana < 50 then return end	
	self._mana = self._mana - 50
	
	local a = Objects.Actor{ _spriteSheet = spriteSheetManager.sheet('male_body_light') }
	a.update = function(this, dt)
		local hx, hy = self:screenToHex(a._position[1], a._position[2])
		local tile = self._board._map:tile(hx, hy)
		if tile then
			if not tile.filled then 
				a._scene:removeComponent(a) 
			end			
			if tile.goal then	
				self._score = self._score + 1000
				a._scene:removeComponent(a)
			end
		end
		Objects.Actor.update(a, dt)
	end
	a:direction('up')
	a:animation('walk')			
	a._velocity[1] = 0
	a._velocity[2] = -20
	a._position[1] = selectedTile.screenX + self._hexWideWidth / 2
	a._position[2] = selectedTile.screenY + self._hexHeight * 0.75
	a:update(0)				
	self._scene:addComponent(a)			
end

--
--  Updates the component
--
function _M:update(dt)
	self._roundTime = self._roundTime - dt
	if self._roundTime <= 0 then
		self._roundTime = 0
	end
	
	if love.keyboard.isDown('s') then
		self._currentSpell = self.castCreateMindlessMinionSpell
	end
	if love.keyboard.isDown('a') then
		self._currentSpell = self.castCreateTemporaryFloorSpell
	end
	
	-- mana regen	
	self._mana = self._mana + self._manaRegenRate * dt
	if self._mana > self._maxMana then
		self._mana = self._maxMana
	end

	local mx, my = love.mouse.getPosition()	
	local hx, hy = self:screenToHex(mx, my)
	
	local currentTile = self._board._map:tile(hx, hy)
	if currentTile and not currentTile.disabled and not currentTile.locked then
		if love.mouse.isDown('l') then		
			self.mouselDown = true
		else
			if self.mouselDown then		
				if self._currentSpell then
					self:_currentSpell(currentTile)
				end
			end	
			self.mouselDown = false
		end

		if previousTile then
			previousTile.hilighted = false
		end	
		currentTile.hilighted = true
		previousTile = currentTile	
	end		
end