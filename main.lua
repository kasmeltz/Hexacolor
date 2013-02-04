local imageManager = require 'imageManager'
local fontManager = require 'fontManager'
local sceneManager = require 'gameSceneManager'
local gameScene = require 'gameScene'

local hexgamecomponent = require 'hexgamecomponent'
local hexgameboard = require 'hexgameboard'

require 'camera'

require 'loadSpriteSheets'

local previousTile

function love.load()
	math.randomseed(os.time())
	
	local board = hexgameboard:new(18, 23, 7)
		
	for tile in board._map:tiles() do
		if not tile.disabled then 
			tile.filled = true
			tile.color = { 20, 20, 100, 255 }
		end
	end
		
	board._map:radialTiles(18, 23, 2, 
		function(tile)
			tile.filled = false
		end)
		
	local tile = board._map:tile(18,23)
	tile.filled = true
	tile.color = { 0, 255, 0, 255 }
	tile.goal = true
	
	local hgc = hexgamecomponent:new(board)
	hgc:hexagonScale(50,40)
	hgc:setHexScreenMapping(18, 23, 380, 280)
	hgc._drawOrder = 0
		
	local gs = gameScene:new()	
	gs._orderedDraw = true
	--gs._showCollisionBoxes = true
	
	local c = camera:new()
	gameScene:camera(c)	
	
	gs:addComponent(hgc)
	
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