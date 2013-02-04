--[[

soundManager.lua
January 10th, 2013

]]
local love = love

module (...)

local sounds = {}

--
--  Returns the sound specified by the path
--	loading it as a new resource if it doesn't already exist
--
function load(path, st)
	if sounds[path] then 
		return sounds[path]
	end
	
	sounds[path] = love.audio.newSource( path, st )
	return sounds[path] 
end