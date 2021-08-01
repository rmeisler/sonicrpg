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
	local Move = require "actions/Move"
	local shine = require "lib/shine"
	
	local SpriteNode = require "object/SpriteNode"
	local FactoryBot = require "object/FactoryBot"
	
	scene.player.collisionHSOffsets = {
		right_top = {x = 0, y = 0},
		right_bot = {x = 0, y = 0},
		left_top = {x = 0, y = 0},
		left_bot = {x = 0, y = 0},
	}
	
	if not GameState:isFlagSet("deathegg_opening") then
		return Action()
	end
	
	GameState:setFlag("deathegg_opening")
	
	local fbot = scene.objectLookup.FactoryBot1
	
	return BlockPlayer {
		Wait(1),
		Ease(scene.camPos, "x", -150, 1),
		Wait(1),
		PlayAudio("sfx", "lockon", 1.0, true),
		Do(function()
			terminal.sprite:setAnimation("num_1")
		end),
		Wait(0.5),
		Do(function()
			terminal.sprite:setAnimation("idle")
		end),
		Wait(0.5),
		PlayAudio("sfx", "lockon", 1.0, true),
		Do(function()
			terminal.sprite:setAnimation("num_6")
		end),
		Wait(0.5),
		Do(function()
			terminal.sprite:setAnimation("idle")
		end),
		Wait(0.5),
		PlayAudio("sfx", "lockon", 1.0, true),
		Do(function()
			terminal.sprite:setAnimation("num_8")
		end),
		Wait(0.5),
		Do(function()
			terminal.sprite:setAnimation("idle")
		end),
		Wait(0.5),
		PlayAudio("sfx", "lockon", 1.0, true),
		Do(function()
			terminal.sprite:setAnimation("num_3")
		end),
		Wait(0.5),
		PlayAudio("sfx", "levelup", 1.0, true),
		Do(function()
			terminal.sprite:setAnimation("idle")
		end),
		Wait(0.5),
		Parallel {
			Move(fbot, scene.objectLookup.Waypoint),
			Serial {
				Wait(1),
				Ease(scene.camPos, "x", 0, 1)
			}
		},
		Do(function()
			fbot.x = 0
			fbot.y = 0
			fbot.sprite.visible = false
			scene.player.sprite.visible = true
			scene.cinematicPause = false
		end)
	}
end
