return function(scene)
	local Transform = require "util/Transform"
	local Rect = unpack(require "util/Shapes")
	local Layout = require "util/Layout"

	local Action = require "actions/Action"
	local TypeText = require "actions/TypeText"
	local Menu = require "actions/Menu"
	local MessageBox = require "actions/MessageBox"
	local PlayAudio = require "actions/PlayAudio"
	local Ease = require "actions/Ease"
	local Parallel = require "actions/Parallel"
	local Serial = require "actions/Serial"
	local Wait = require "actions/Wait"
	local Repeat = require "actions/Repeat"
	local Spawn = require "actions/Spawn"
	local Do = require "actions/Do"
	local Animate = require "actions/Animate"
	local shine = require "lib/shine"
	local SpriteNode = require "object/SpriteNode"
	
	scene.player.collisionHSOffsets = {
		right_top = {x = 0, y = 0},
		right_bot = {x = 0, y = 0},
		left_top = {x = 0, y = 0},
		left_bot = {x = 0, y = 0},
	}

	local wallLayer
	for _,layer in pairs(scene.map.layers) do
		if layer.name == "RightWall" then
            wallLayer = layer
			break
        end
	end
	
	if  GameState:isFlagSet(scene.mapName..".squares_complete") and
		not scene.objectLookup.RightEntranceBlock:isRemoved()
	then
		scene.objectLookup.RightEntrance.y = scene.objectLookup.RightEntranceBlock.y
		scene.objectLookup.RightEntrance.object.y = scene.objectLookup.RightEntranceBlock.y
		scene.objectLookup.RightEntrance:updateCollision()
		scene.objectLookup.RightEntranceBlock:remove()
		wallLayer.offsety = -32*3
	end
	
	return Action()	
end
