--[[

gameScene.lua
January 9th, 2013

]]
local love = love

local setmetatable, pairs, ipairs, table, math
	= setmetatable, pairs, ipairs, table, math
		
module(...)

--
--  Creates a game scene
--
function _M:new()	
	local o = { 
		_drawables = {},
		_updateables = {},
		_collidables = {},
		_removals = {},
		_orderedDraw = false,
		_showCollisionBoxes = false
	}		
	
	self.__index = self
	local t = setmetatable(o, self)	
	
	-- default collision buckets
	t:createCollisionBuckets()
	
	return t
end

--
--  Creates the collision buckets for this scene
--
function _M:createCollisionBuckets(columns, bucketCellSize, sx, sy, w, h)
	local columns = columns or 100
	local bucketCellSize = bucketCellSize or 500
	local sx = sx or 0
	local sy = sy or 0
	local w = w or 4000
	local h = h or 4000
	
	self._buckets = {}
	self._buckets.hash = function(x, y)
		return math.floor(x / bucketCellSize) + 
			(math.floor(y / bucketCellSize) * columns) + 1
	end		
	
	for y = sy, sy + h, bucketCellSize do
		for x = sx, sx + w, bucketCellSize do
			self._buckets[self._buckets.hash(x, y)] = {}
		end
	end	
end

--
--  Draws the collision box for an object
--
function _M:drawCollisionBox(c)
	local b = c._boundary

	local x1 = 
		math.floor((b[1] * self._camera._zoomX) - self._camera._cwzx)
	local x2 = 
		math.floor((b[3] * self._camera._zoomX) - self._camera._cwzx)
	local y1 =
		math.floor((b[2] * self._camera._zoomY) - self._camera._cwzy)
	local y2 =
		math.floor((b[4] * self._camera._zoomY) - self._camera._cwzy)					
	love.graphics.setColor{255,255,255,255}
	love.graphics.rectangle('line',x1,y1,x2-x1,y2-y1)
end

--
--  Draws the game scene
--
function _M:draw()
	if self._orderedDraw then
		local sorted = {}
		for k, v in pairs(self._drawables) do
			sorted[#sorted+1] = v
		end
		table.sort(sorted, function(a,b) return a._drawOrder < b._drawOrder end)
		for _, c in ipairs(sorted) do
			c:draw(self._camera)
			if self._showCollisionBoxes then
				if c._boundary then
					self:drawCollisionBox(c)
				end
			end
		end
	else
		for _, c in pairs(self._drawables) do
			c:draw(self._camera)
		end	
	end	
end

--
--  Removes a component from the game world
--
function _M:doRemove(c)
	if c._bucketIds then
		-- unregister the component from the buckets
		for bucket, _ in pairs(c._bucketIds) do
			if self._buckets[bucket] then
				self._buckets[bucket][c._id] = nil
			end
		end				
	end

	self._drawables[c] = nil
	self._updateables[c] = nil
	self._collidables[c] = nil
end
	
--
--  Updates the game scene
--
function _M:update(dt)
	for k, v in pairs(self._removals) do		
		self:doRemove(v)
		self._removals[k] = nil
	end	
			
	for _, c in pairs(self._updateables) do
		c:update(dt)	
	end
	for _, c in pairs(self._collidables) do
		c:registerBuckets(self._buckets)
	end
	for _, c in pairs(self._collidables) do
		c:checkCollision(self._buckets)
	end	
end

--
--  Adds a component
--
function _M:addComponent(c)
	if c.draw then
		self._drawables[c] = c
	end
	if c.update then
		self._updateables[c] = c
	end	
	if c.registerBuckets then
		c:calculateBoundary()
		c:registerBuckets(self._buckets)
	end
	if c.checkCollision then
		self._collidables[c] = c
	end
end

--
--  Removes a component
--
function _M:removeComponent(c)
	self._removals[c] = c
end

--
--  Sets or gets the camera for this scene
--
function _M:camera(c)
	if not c then return self._camera end
	self._camera = c
end
