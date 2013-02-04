--[[

spriteSheetManager.lua
January 15th, 2013

]]
local love = love

module (...)

local sheets = {}

--
--  Gets or sets a sheet in the manager
--
function sheet(name, ss)
	if not ss then return sheets[name] end
	sheets[name] = ss
end