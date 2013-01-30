--[[

fontManager.lua
January 9th, 2013

]]
local love = love

module (...)

local fonts = {}

function Load(name, path, size)
	if fonts[name .. size] then 
		return fonts[name .. size]
	end
	
	fonts[name .. size] = love.graphics.newFont(path, size)
	return fonts[name .. size] 
end