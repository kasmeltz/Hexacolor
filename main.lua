local imageManager = require 'imageManager'
local fontManager = require 'fontManager'
local sceneManager = require 'gameSceneManager'
local gameScene = require 'gameScene'

local defaultFont = love.graphics.newFont(11)
local bigFont = love.graphics.newFont(48)

local oldHx, oldHy
local white = { 255, 255, 255, 255 }
local grey = { 80, 80, 80, 255 }

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

local tiles = {}
for y = 1, 100 do
	tiles[y] = {}
	for x = 1, 100 do
		tiles[y][x] = { filled = false }
	end
end

for i = 1, 100 do	
	local x = math.random(10,40)
	local y = math.random(1,30)
	local r = math.random(0,2)
	local g = math.random(0,2)
	local b = math.random(0,2)
	
	tiles[y][x].color = { r * 125, g * 125, b * 125, 255 }
	tiles[y][x].filled = true
end

function love.load()
	math.randomseed( os.time() )

	local xoff = -500
	local yoff = -1000
	local w = 80
	local nw = w * 0.75
	local h = 60
	local drawingColor = nil
			
	local gs = gameScene:new()	
	gs:addComponent{
		draw = function()
			love.graphics.setFont(defaultFont)
			love.graphics.setLineWidth(2)		
						
			local line_color
			
			for y = 1, 40 do
				for x = 1, 40 do
					local sx = (nw * x) + xoff
					local sy = (h * (x * 0.5 + y)) + yoff

					local tile = tiles[y][x]
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
					love.graphics.setColor(80,80,80,255)	
					love.graphics.print(x .. ',' .. y, sx, sy)
					love.graphics.setColor(0,255,0,255)
					love.graphics.setFont(bigFont)	
					love.graphics.print(mx .. ',' .. my, 0, 0)
					love.graphics.print(hx .. ',' .. hy, 0, 50)
					]]
				end
			end
		end,
		update = function(self, dt)			
			local mx, my = love.mouse.getPosition()	
			local hmx = mx - xoff - 10
			local hmy = my - yoff + 0
			
			local hx = math.floor(hmx / nw)
			local hy = math.floor(hmy / h - hx * 0.5)
			
			if love.mouse.isDown('l') then						
				if tiles[hy][hx].color then
					drawingColor = tiles[hy][hx].color
				end
			else
				drawingColor = nil
			end
			
			if drawingColor then
				tiles[hy][hx].color = drawingColor
				tiles[hy][hx].filled = true
			end
			
			if oldHx and oldHy then
				tiles[oldHy][oldHx].hilighted = false
			end	
			tiles[hy][hx].hilighted = true
			
			oldHx = hx
			oldHy = hy
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