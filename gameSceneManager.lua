--[[

gameSceneManager.lua
January 9th, 2013

]]

local print = print

module (...)

local scenes = {}
local currentScene = nil
local switchCounter = 0
local switchTo = nil

--
--  Adds a scene to the scene manager
--
function addScene(name, gs)
	scenes[name] = gs
end

--
--  Removes a scene from the scene manager
--
function removeScene(name)
	scenes[name] = nil
end

--
--  Gets a scene from the scene manager
--
function getScene(name)
	return scenes[name]
end

--
--  Switches scenes
--
function switch(name, timeDelay)
	if switchCounter > 0 then return end
	
	local gs = scenes[name]
	if not gs then return end

	switchCounter = timeDelay or 0
	switchTo = gs
end

--
--  Updates the current scene
--
function update(dt)	
	if switchTo then
		switchCounter = switchCounter - dt		
		if switchCounter <= 0 then
			if currentScene ~= nil then
				if currentScene.finish then
					currentScene:finish()
				end
			end
				
			currentScene = switchTo
			
			if currentScene.begin then
				currentScene:begin()
			end
			
			switchTo = nil
			switchCounter = 0				
		end
	end

	if currentScene ~= nil then
		currentScene:update(dt)
	end
end

--
--  Draws the current scene
--
function draw()
	if currentScene ~= nil then
		currentScene:draw()
	end
end