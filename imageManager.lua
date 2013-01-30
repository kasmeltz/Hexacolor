--[[

imageManager.lua
January 9th, 2013

]]
local love = love

module (...)

local images = {}

function Load(name, path)
	if images[name] then 
		return images[name] 
	end
	
	images[name] = love.graphics.newImage(path)
	return images[name] 
end

