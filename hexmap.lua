--[[

hexmap.lua
January 30th, 2013

]]
local setmetatable, ipairs, math
	= setmetatable, ipairs, math
		
module(...)

--
--  Creates a hex map
--
function _M:new(w, h)	
	local o = { 
		_width = w,
		_height = h,
		_tiles = {},
		_neighbourMap = {
			x = { 0, 1, 1, 0, -1, -1 },
			y = { 1, 0, -1, -1, 0, 1 }
		}		
	}
		
	self.__index = self
	o = setmetatable(o, self)		
	o:initialize()
	
	return o
end

--
--  Initializes the map
--
function _M:initialize()
	-- create base tile structure
	for y = 1, self._height do
		self._tiles[y] = {}
		for x = 1, self._width do
			self._tiles[y][x] = { 
				x = x, 
				y = y
			}
		end
	end

	-- create neighbour structure for a tile
	local function createNeighbours(tile)
		tile.neighbours = {}
		local x = tile.x
		local y = tile.y
		
		for i = 1, #self._neighbourMap.y do
			local n = self:tile(x + self._neighbourMap.x[i],
					y + self._neighbourMap.y[i])
			if n then 
				tile.neighbours[#tile.neighbours + 1] = n
			end
		end				
	end
	
	-- create neighbour structure for each tile
	for y = 1, self._height do
		for x = 1, self._width do
			createNeighbours(self._tiles[y][x])
		end
	end	
end

--
--  Returns an iterator over all of the tiles
--
function _M:tiles()
	local x = 0
	local y = 1
	return function ()
		x = x + 1
		if x > #self._tiles[y] then 
			x = 1
			y = y +1
			if y > #self._tiles then
				return nil
			end
		end
		return self._tiles[y][x]
    end
end

--
--  Returns a tile from the map or nil if the tile
--  doesn't exist
--
function _M:tile(x, y)
	if y < 1 or y > #self._tiles then return nil end
	if x < 1 or x > #self._tiles[y] then return nil end
	return self._tiles[y][x]
end

--
--  Returns the distance (in hexes) between two tiles
--
function _M:distance(tile1, tile2)
	local x = tile1.x - tile2.x
	local y = tile1.y - tile2.y	
	return (math.abs(x) + math.abs(y) + math.abs(x+y)) / 2
end

--
--  Enables all tiles a certain radius from the provided grid location
--
function _M:enableRadialTiles(x, y, size)
	local ct = self:tile(x,y)
	ct.disabled = false
		
	-- enable all tiles a certain distance from center tile
	for tile in self:tiles() do
		if self:distance(ct, tile) < size then
			tile.disabled = false
		end
	end
end

--
--  Enables tiles in a star pattern from the provided grid location
--
function _M:enableStarTiles(x, y, size)
	local tile = self:tile(x,y)
	tile.disabled = false
	
	for i = 1, #self._neighbourMap.y do
		for k = 1, size do
			local nx = self._neighbourMap.x[i] * k
			local ny = self._neighbourMap.y[i] * k
			local n = self:tile(x + nx, y + ny)
			if n then 
				n.disabled = false
			end
		end
	end				
end


		
--
--  Tests if there is a path between the first and second tile
--  If there is no path the function returns false
--  If there is a path the function returns a table that 
--  contains the tiles that compose the path
--
function _M:pathExists(x1, y1, x2, y2, connectionFn)
	local first = self:tile(x1, y1)
	local second = self:tile(x2, y2)
	
	if not first then
		return nil, 'The first tile does not exist.'
	end
	if not second then 
		return nil, 'The second tile does not exist.'
	end	
	
	local visited = {}
	local toVisit = {}
	local current = nil

	-- start at the first tile
	toVisit[#toVisit+1] = first
	
	-- loop until there are no tiles to visit
	repeat 
		-- get the next tile to visit
		current = toVisit[#toVisit]		
		-- mark tile as visited		
		visited[current] = true
		-- remove the tile from the list of tiles to visit
		toVisit[#toVisit] = nil
		-- if we reached the destination then return the table of visited items
		if current == second then
			return visited
		end		
		
		-- add all neighbouring tiles that pass
		-- the connection function to the toVisit table
		-- and that haven't already been visited
		for _, v in ipairs(current.neighbours) do
			if not visited[v] and connectionFn(current, v) then
				toVisit[#toVisit+1] = v
			end
		end				
	until #toVisit == 0
	
	return false
end