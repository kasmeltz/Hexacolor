local imageManager = require 'imageManager'
local fontManager = require 'fontManager'
local sceneManager = require 'gameSceneManager'
local gameScene = require 'gameScene'

local hexconnectorgamecomponent = require 'hexconnectorgamecomponent'
local hexconnectorboard = require 'hexconnectorboard'

local previousTile

function love.load()
	math.randomseed(os.time())
	
	local board = hexconnectorboard:new(18, 23, 7)
	board:addConnector(12,29,22,24,{ 255, 0, 0, 255 })
	board:addConnector(13,28,21,24,{ 0, 0, 255, 255 })
	board:addConnector(17,20,18,25,{ 255, 0, 255, 255 })
	board:addConnector(15,23,21,20,{ 0, 255, 0, 255 })
	board:addConnector(13,22,24,21,{ 255, 255, 0, 255 })
	local hgc = hexconnectorgamecomponent:new(board)
	
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