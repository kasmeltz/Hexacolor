--[[

imageManager.lua
January 9th, 2013

]]
local love = love

module (...)

local images = {}

--
--  Returns the image specified by the path
--	loading it as a new resource if it doesn't already exist
--
function load(path)
	if images[path] then 
		return images[path] 
	end
	
	images[path] = love.graphics.newImage(path)
	return images[path] 
end