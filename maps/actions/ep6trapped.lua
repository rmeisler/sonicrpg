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
	
	local elevatorLayer = scene:findLayer("Elevator")

	return BlockPlayer {
		Do(function()
			scene.player.sprite.visible = false
			scene.player.dropShadow.hidden = true
		end),
		Wait(2),
		--PlayAudio("music", "ep6intro", 1, true),
		MessageBox{message="Sally: Alright guys, I'm loading the training program now...", closeAction=Wait(2)},
		Parallel {
			MessageBox{message="Sally: Let's do it to it!", closeAction=Wait(2)},
			Ease(scene.camPos, "x", 3400, 0.12)
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
		Do(function()
			scene.objectLookup.Logan.sprite.sortOrderY = 10000
		end),
		Parallel {
			Animate(scene.objectLookup.Logan.sprite, "pose"),
			Animate(scene.objectLookup.Rotor.sprite, "pose"),
		},
		MessageBox{message="Sally: Nice job!", closeAction=Wait(1)},
		Ease(scene.camPos, "x", 2300 - 32, 0.5),
		
		Do(function() scene.objectLookup.Firebird.hidden = false end),
		Ease(scene.objectLookup.Firebird, "y", 240, 5, "quad"),
		scene:screenShake(30, 20),
		Wait(0.2),
		Animate(scene.objectLookup.Bunnie.sprite, "shock"),
		Animate(scene.objectLookup.Ivan.sprite, "attitude"),
		Parallel {
			scene.objectLookup.Bunnie:hop(),
			scene.objectLookup.Ivan:hop(),
		},
		Wait(1),
		Animate(scene.objectLookup.Firebird.sprite, "fireattack"),
		Wait(0.5),
		Move(scene.objectLookup.Bunnie, scene.objectLookup.BunnieWP, "walk"),
		Animate(scene.objectLookup.Bunnie.sprite, "punchup"),
		PlayAudio("sfx", "smack", 1, true, nil, true),
		Animate(scene.objectLookup.ElevatorControl.sprite, "crushed"),
		PlayAudio("sfx", "elevatorend", 1, true),
		Parallel {
			Ease(elevatorLayer, "offsety", function() return elevatorLayer.offsety + 1000 end, 4, "quad"),
			Ease(scene.objectLookup.Firebird, "y", function() return scene.objectLookup.Firebird.y + 1000 end, 4, "quad")
		},
		Wait(0.5),
		Animate(scene.objectLookup.Bunnie.sprite, "pose"),
		Wait(0.5),
		MessageBox{message="Sally: Good problem solving!", closeAction=Wait(1)},
		
		Ease(scene.camPos, "x", 1200 - 32, 0.5),
		Wait(1),
		Do(function()
			scene.objectLookup.LeftSpikeWall.hidden = false
			scene.objectLookup.RightSpikeWall.hidden = false
			scene.objectLookup.Antoine.sprite.sortOrderY = 10000
		end),
		Ease(scene.objectLookup.LeftSpikeWall, "y", 400, 5, "quad"),
		scene:screenShake(30, 20),
		Animate(scene.objectLookup.Antoine.sprite, "peekleft"),
		Wait(0.5),
		Ease(scene.objectLookup.RightSpikeWall, "y", 400, 5, "quad"),
		scene:screenShake(30, 20),
		Animate(scene.objectLookup.Antoine.sprite, "peekright"),
		Wait(0.5),
		Animate(scene.objectLookup.Antoine.sprite, "shock"),
		scene.objectLookup.Antoine:hop(),
		Do(function()
			scene.objectLookup.Antoine.sprite:setAnimation("tremble")
		end),
		MessageBox{message="Antoine: I-I-I am not knowing what to be doing!!", closeAction=Wait(2)},
		PlayAudio("sfx", "elevator", 1, true),
		Parallel {
			Ease(scene.objectLookup.LeftSpikeWall, "x", scene.objectLookup.Antoine.x, 0.08, "linear"),
			Ease(scene.objectLookup.RightSpikeWall, "x", scene.objectLookup.Antoine.x, 0.08, "linear"),
			Serial {
				Wait(1.5),
				MessageBox{message="Sally: Hmm{p60}, Sonic should be in this scenario with you.", closeAction=Wait(1.5)},
				Wait(1.5),
				MessageBox{message="Antoine: Sonic!!", closeAction=Wait(1)},
				Animate(scene.objectLookup.Antoine.sprite, "scream"),
				scene.objectLookup.Antoine:hop(),
				Do(function()
					scene:changeScene{map="greatforest_ep6_intro1", fadeInSpeed=20, fadeOutSpeed=20, fadeOutMusic=false}
				end)
			}
		}
	}
end
