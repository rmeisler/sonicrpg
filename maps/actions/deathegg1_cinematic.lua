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
	local BlockPlayer = require "actions/BlockPlayer"
	local shine = require "lib/shine"
	local SpriteNode = require "object/SpriteNode"
	
	scene.player.collisionHSOffsets = {
		right_top = {x = 0, y = 0},
		right_bot = {x = 0, y = 0},
		left_top = {x = 0, y = 0},
		left_bot = {x = 0, y = 0},
	}
	
	scene.player.sprite.visible = false
	scene.cinematicPause = true
	
	return BlockPlayer {
		Wait(1),
		Ease(scene.camPos, "x", -150, 1),
		Wait(2),
		PlayAudio("sfx", "lockon", 1.0, true),
		Do(function()
			scene.objectLookup.Terminal.sprite:setAnimation("num_1")
		end),
		Wait(1),
		Do(function()
			scene.objectLookup.Terminal.sprite:setAnimation("idle")
		end),
		Wait(1),
		PlayAudio("sfx", "lockon", 1.0, true),
		Do(function()
			scene.objectLookup.Terminal.sprite:setAnimation("num_6")
		end),
		Wait(1),
		Do(function()
			scene.objectLookup.Terminal.sprite:setAnimation("idle")
		end),
		Wait(1),
		PlayAudio("sfx", "lockon", 1.0, true),
		Do(function()
			scene.objectLookup.Terminal.sprite:setAnimation("num_6")
		end),
		Wait(1),
		Do(function()
			scene.objectLookup.Terminal.sprite:setAnimation("idle")
		end),
		Wait(1),
		PlayAudio("sfx", "lockon", 1.0, true),
		Do(function()
			scene.objectLookup.Terminal.sprite:setAnimation("num_8")
		end),
		Wait(1),
		Do(function()
			scene.objectLookup.Terminal.sprite:setAnimation("idle")
		end),
		Wait(1),
		Ease(scene.camPos, "x", 0, 1),
		Do(function()
			scene.player.sprite.visible = true
			scene.cinematicPause = false
		end)
	}
end
