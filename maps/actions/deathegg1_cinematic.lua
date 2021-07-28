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
	
	if  scene.reenteringFromBattle or
		scene.player.x > 400 or
		not GameState:isFlagSet("deathegg_checkleft1")
	then
		return Action()
	end
	
	local fbot = scene.objectLookup.FactoryBot1
	if not fbot or fbot:isRemoved() then
		fbot = FactoryBot(
			scene,
			{name="objects"},
			{
				name = "FactoryBot2",
				x = 534,
				y = 1248 - 32,
				width = 64,
				height = 32,
				properties = {
					battle = "data/monsters/factorybot.lua",
					battleOnColllide = true,
					disappearAfterBattle = true,
					defaultAnim = "idleup",
					ghost = true,
					sprite = "art/sprites/factorybot.png"
				}
			}
		)
		scene:addObject(fbot)
		scene.objectLookup.FactoryBot1 = fbot
	else
		fbot.x = 534
		fbot.y = 1248 - fbot.sprite.h*2
		fbot.sprite.visible = true
		fbot.sprite:setAnimation("idleup")
	end
	
	scene.player.sprite.visible = false
	scene.cinematicPause = true
	
	local terminal = scene.objectLookup.Terminal
	
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
