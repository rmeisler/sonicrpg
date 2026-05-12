return function(scene, hint)
	local Transform = require "util/Transform"
	local Rect = unpack(require "util/Shapes")
	local Layout = require "util/Layout"

	local Action = require "actions/Action"
	local TypeText = require "actions/TypeText"
	local Menu = require "actions/Menu"
	local MessageBox = require "actions/MessageBox"
	local Move = require "actions/Move"
	local PlayAudio = require "actions/PlayAudio"
	local Ease = require "actions/Ease"
	local Parallel = require "actions/Parallel"
	local Serial = require "actions/Serial"
	local Executor = require "actions/Executor"
	local Wait = require "actions/Wait"
	local Repeat = require "actions/Repeat"
	local Do = require "actions/Do"
	local AudioFade = require "actions/AudioFade"
	local Spawn = require "actions/Spawn"
	local BlockPlayer = require "actions/BlockPlayer"
	local Animate = require "actions/Animate"
	local SpriteNode = require "object/SpriteNode"

	scene.player.sprite.visible = false
	scene.player.dropShadow.hidden = true

	return BlockPlayer {
		Do(function()
			scene.player.sprite.visible = false
			scene.player.dropShadow.hidden = true
		end),
		Wait(2),
		MessageBox{message="Sally: Alright guys{p40}, you're all doing great!", closeAction=Wait(2)},
		Parallel {
			MessageBox{message="Sally: Let's just run through it one more time.", closeAction=Wait(2)},
			Ease(scene.camPos, "x", 3400, 0.1)
		},
		PlayAudio("music", "fftraining", 1, true),
		Wait(1),
		Spawn(Serial {
			Do(function()
				scene.objectLookup.Gas1.sprite:setAnimation("start")
				scene.objectLookup.Gas2.sprite:setAnimation("start")
				scene.objectLookup.Gas3.sprite:setAnimation("backward_start")
				scene.objectLookup.Gas4.sprite:setAnimation("backward_start")

				scene.objectLookup.Gas1.hidden = false
				scene.objectLookup.Gas2.hidden = false
				scene.objectLookup.Gas3.hidden = false
				scene.objectLookup.Gas4.hidden = false
			end),
			Parallel {
				Animate(scene.objectLookup.Gas1.sprite, "release"),
				Animate(scene.objectLookup.Gas2.sprite, "release"),
				Animate(scene.objectLookup.Gas3.sprite, "backward_release"),
				Animate(scene.objectLookup.Gas4.sprite, "backward_release")
			},
			Do(function()
				scene.objectLookup.Gas1.sprite:setAnimation("idle")
				scene.objectLookup.Gas2.sprite:setAnimation("idle")
				scene.objectLookup.Gas3.sprite:setAnimation("backward")
				scene.objectLookup.Gas4.sprite:setAnimation("backward")
			end)
		}),
		Wait(1.5),
		Animate(scene.objectLookup.Logan.sprite, "shock"),
		Animate(scene.objectLookup.Rotor.sprite, "shock"),
		Parallel {
			scene.objectLookup.Logan:hop(),
			scene.objectLookup.Rotor:hop(),
		},
		Wait(1),
		Parallel {
			Move(scene.objectLookup.Logan, scene.objectLookup.Logan_WP, "walk"),
			Move(scene.objectLookup.Rotor, scene.objectLookup.Rotor_WP, "walk")
		},
		Parallel {
			Animate(scene.objectLookup.Logan.sprite, "idleup"),
			Animate(scene.objectLookup.Rotor.sprite, "idleup"),
		},
		PlayAudio("sfx", "nicolebeep", 1),
		PlayAudio("sfx", "nicolebeep", 1),
		PlayAudio("sfx", "nicolebeep", 1),
		Wait(0.2),
		PlayAudio("sfx", "nicolebeep", 1),
		Wait(0.2),
		Parallel {
			Ease(scene.objectLookup.Gas1.sprite.color, 4, 0, 1),
			Ease(scene.objectLookup.Gas2.sprite.color, 4, 0, 1),
			Ease(scene.objectLookup.Gas3.sprite.color, 4, 0, 1),
			Ease(scene.objectLookup.Gas4.sprite.color, 4, 0, 1)
		},
		Parallel {
			Animate(scene.objectLookup.Logan.sprite, "pose"),
			Animate(scene.objectLookup.Rotor.sprite, "pose"),
		},
		MessageBox{message="Sally: Nice job!", closeAction=Wait(1)},
		Ease(scene.camPos, "x", 2300 - 32, 0.5),
		
		Do(function() scene.objectLookup.Firebird.hidden = false end),
		Ease(scene.objectLookup.Firebird, "y", 240, 5, "quad"),
		Ease(scene.objectLookup.Firebird, "y", function() return scene.objectLookup.Firebird.y - 3 end, 15, "quad"),
		Ease(scene.objectLookup.Firebird, "y", function() return scene.objectLookup.Firebird.y + 3 end, 15, "quad"),
		Ease(scene.objectLookup.Firebird, "y", function() return scene.objectLookup.Firebird.y - 1 end, 15, "quad"),
		Ease(scene.objectLookup.Firebird, "y", function() return scene.objectLookup.Firebird.y + 1 end, 15, "quad"),
		Wait(1),
		Animate(scene.objectLookup.Bunnie.sprite, "shock"),
		Animate(scene.objectLookup.Ivan.sprite, "attitude"),
		Parallel {
			scene.objectLookup.Bunnie:hop(),
			scene.objectLookup.Ivan:hop(),
		},
		Animate(scene.objectLookup.Firebird.sprite, "fireattack"),
		Wait(1),
		Move(scene.objectLookup.Bunnie, scene.objectLookup.BunnieWP, "walk"),
		Animate(scene.objectLookup.Bunnie.sprite, "idleup"),
		PlayAudio("sfx", "error", 1),
		Wait(0.2),
		PlayAudio("sfx", "error", 1, true),
		Wait(0.1),
		PlayAudio("sfx", "error", 1, true),
		Wait(0.1),
		PlayAudio("sfx", "error", 1, true),
		

		Do(function()
			--scene:changeScene{map="knothole_ep5", fadeInSpeed=0.2, fadeOutSpeed=0.2, fadeOutMusic=true, hint="epilogue_leon", spawnPoint="EpilogueSpawn2", nighttime=true}
		end)
	}
end
