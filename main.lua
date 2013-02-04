local imageManager = require 'imageManager'
local fontManager = require 'fontManager'
local sceneManager = require 'gameSceneManager'
local gameScene = require 'gameScene'

local hexgamecomponent = require 'hexgamecomponent'
local hexgameboard = require 'hexgameboard'

--require 'loadSpriteSheets'

local previousTile

function love.load()
	math.randomseed(os.time())
	
	local board = hexgameboard:new(18, 23, 7)
	local hgc = hexgamecomponent:new(board)
	hgc:hexagonScale(50,40)
	hgc:setHexWorldMapping(18, 23, 380, 280)
	
	local gs = gameScene:new()	
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