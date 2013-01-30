local imageManager = require 'imageManager'
local fontManager = require 'fontManager'
local sceneManager = require 'gameSceneManager'
local gameScene = require 'gameScene'

local hexmap = require 'hexmap'

local defaultFont = love.graphics.newFont(11)
local bigFont = love.graphics.newFont(24)

local previousTile
local white = { 255, 255, 255, 255 }
local grey = { 80, 80, 80, 255 }

local connectors = {
	{ 
		color = { 255, 0, 0, 255 }, 
		x1 = 12, y1 = 29,
		x2 = 22, y2 = 24,
	},
	{ 
		color = { 0, 0, 255, 255 },
		x1 = 11, y1 = 29,
		x2 = 21, y2 = 24,
	},
	{ 
		color = { 255, 0, 255, 255 },
		x1 = 17, y1 = 20,
		x2 = 18, y2 = 25,
	}	
}

function drawHexagon(m, x, y, w, h)
	local m = m or 'fill'
	local x = x or 400
	local y = y or 300
	local w = w or 50
	local h = h or 40

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

function love.load()
	math.randomseed(os.time())
	
	local tile 
	
	local map = hexmap:new(50,50)
	
	-- start with all tiles not filled
	for tile in map:tiles() do
		tile.filled = false
	end
	
	-- set up the connectors
	for _, c in ipairs(connectors) do
		c.connected = false	
		tile = map:tile(c.x1, c.y1)
		tile.color = c.color
		tile.filled = true
		tile = map:tile(c.x2, c.y2)
		tile.color = c.color
		tile.filled = true		
	end
	
	local xoff = -300
	local yoff = -1000
	local w = 50
	local nw = w * 0.75
	local h = 40
	local drawingColor = nil
			
	local gs = gameScene:new()	
	gs:addComponent{
		draw = function()
			love.graphics.setFont(defaultFont)
			love.graphics.setLineWidth(2)		
						
			local line_color
			
			for y = 5, 45 do
				for x = 5, 45 do
					local sx = (nw * x) + xoff
					local sy = (h * (x * 0.5 + y)) + yoff

					local tile = map:tile(x,y)
					if tile.hilighted then 
						line_color = white
					else
						line_color = tile.color or grey				
					end				
					
					if tile.filled then
						love.graphics.setColor(tile.color)
						drawHexagon('fill', sx, sy, w - 2, h - 2 )
					end
						
					love.graphics.setColor(line_color)
					drawHexagon('line', sx, sy, w - 2, h - 2 )
					
					--[[
					love.graphics.setColor(0, 255, 0, 255)
					love.graphics.print(x .. ',' .. y, sx, sy)
					]]
				end
			end
			
			-- draw the status of the connectors
			
			love.graphics.setFont(bigFont)
			local sx = 0
			local sy = 0
			for k, c in ipairs(connectors) do								
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
		end,
		update = function(self, dt)		
			-- check the connectors
			for _, c in ipairs(connectors) do	
				-- check if the connectors have been connected
				if not c.connected then
					local result = map:pathExists(c.x1, c.y1, c.x2, c.y2,
						function(a, b)
							return 	
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
					local firstColor = map:tile(c.x1, c.y1).color
					local result = map:pathExists(c.x1, c.y1, c.x2, c.y2,
						function(a, b)
							return 
								not b.color or 
								(b.color[1] == firstColor[1]
								and
								b.color[2] == firstColor[2]
								and
								b.color[3] == firstColor[3])
						end)
					if not result then
						c.connected = -1
					end
				end				
			end

			local mx, my = love.mouse.getPosition()	
			local hmx = mx - xoff - 10
			local hmy = my - yoff + 0
			
			local hx = math.floor(hmx / nw)
			local hy = math.floor(hmy / h - hx * 0.5)
			
			local currentTile = map:tile(hx, hy)
			
			if currentTile then
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
				end
				
				if previousTile then
					previousTile.hilighted = false
				end	
				currentTile.hilighted = true
				previousTile = currentTile
			end
		end
	}	
	
	sceneManager.removeScene('hexagons')
	sceneManager.addScene('hexagons', gs)

	sceneManager.switch('hexagons')
end
			
function love.draw()
	sceneManager.draw()
end

function love.update(dt)
	sceneManager.update(dt)
end