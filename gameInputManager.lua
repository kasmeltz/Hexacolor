--[[

gameInputManager.lua
January 9th, 2013

]]

local love = love

local ipairs
	= ipairs

module (...)

keyPressed = {}
keyReleased = {}
mousePressed = {}
mouseReleased = {}

local mouseButtons = { 'l' }
local keys = { 'q', 'w' }

--
--  Updates the input manager
--  
function update()
	for _, k in ipairs(keys) do
		keyReleased[k] = nil
		
		if love.keyboard.isDown(k) then
			keyPressed[k] = true
		else
			if keyPressed[k] then
				keyReleased[k] = true
			end
			keyPressed[k] = false
		end
	end
	
	for _, b in ipairs(mouseButtons) do
		mouseReleased[b] = nil
		
		if love.mouse.isDown(b) then
			mousePressed[b] = true
		else
			if mousePressed[b] then
				mouseReleased[b] = true
			end
			mousePressed[b] = false
		end
	end
end