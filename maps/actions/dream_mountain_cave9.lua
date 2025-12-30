return function(scene, hint)
	local Transform = require "util/Transform"
	local Rect = unpack(require "util/Shapes")
	local Layout = require "util/Layout"

	local Action = require "actions/Action"
	local Animate = require "actions/Animate"
	local TypeText = require "actions/TypeText"
	local Menu = require "actions/Menu"
	local MessageBox = require "actions/MessageBox"
	local PlayAudio = require "actions/PlayAudio"
	local Ease = require "actions/Ease"
	local BlockPlayer = require "actions/BlockPlayer"
	local Parallel = require "actions/Parallel"
	local Serial = require "actions/Serial"
	local Executor = require "actions/Executor"
	local Wait = require "actions/Wait"
	local Do = require "actions/Do"
	local Spawn = require "actions/Spawn"
	local shine = require "lib/shine"
	local AudioFade = require "actions/AudioFade"
	local SpriteNode = require "object/SpriteNode"
	local NameScreen = require "actions/NameScreen"
	local Player = require "object/Player"

	if hint == "after_terrabot" then
		scene.player.sprite.visible = false
		scene.player.dropShadow.hidden = true
		scene.objectLookup.Terrabot:remove()
		scene.partySprites.babyt.sprite:setAnimation("idle")

		return BlockPlayer {
			Do(function()
				scene.player.sprite.visible = false
				scene.player.dropShadow.hidden = true
			end),
			
			PlayAudio("music", "robotnik", 1, true, true),
			Animate(scene.objectLookup.Robotnik.sprite, "angryright"),
			MessageBox{message="Robotnik: My beautiful creation!! {p60}You'll pay for this!", textSpeed=3},
			Parallel {
				scene.partySprites.tails:hop(),
				MessageBox{message="Tails: We won't let you reach the Light, Robotnik!! {p60}Give it up!"}
			},
			Animate(scene.objectLookup.Robotnik.sprite, "idleright"),
			MessageBox{message="Robotnik: He he he... {p60}you dare to challenge me?...", textSpeed=3},
			Parallel {
				Animate(scene.partySprites.babyt.sprite, "roar"),
				scene.partySprites.babyt:hop(),
				MessageBox{message="Baby T: That's right! {p60}We're not scared of you!"}
			},
			Parallel {
				scene.partySprites.b:hop(),
				MessageBox{message="B: It's over, Robotnik."}
			},
			Wait(0.5),
			MessageBox{message="Robotnik: Perhaps I've underestimated your motley crew of misfits.", textSpeed=3},
			Animate(scene.objectLookup.Robotnik.sprite, "idleright"),
			MessageBox{message="Robotnik: Unfortunately for you, {p60}your luck is about to run out!", textSpeed=3},
			AudioFade("music", 1, 0, 1),
			scene:enterBattle {
				opponents = {"robotnik"},
				initiative = "cinematic",
				hint = "after_robotnik"
			}
		}
	end
	
	if hint == "after_robotnik" then
		scene.player.sprite.visible = false
		scene.player.dropShadow.hidden = true
		scene.objectLookup.Robotnik.sprite:setAnimation("veryhurt2")
		scene.partySprites.babyt.sprite:setAnimation("idle")
		return BlockPlayer {
			Do(function()
				scene.player.sprite.visible = false
				scene.player.dropShadow.hidden = true
			end),

			PlayAudio("music", "robotnik", 1, true, true),
			Wait(1),
			MessageBox{message="Robotnik: Ugh... {p60}it appears you've defeated me...", textSpeed=3},
			MessageBox{message="Robotnik: I suppose you'll make your way to the Light now, to make your wish...", textSpeed=3},
			Parallel {
				scene.partySprites.babyt:hop(),
				Animate(scene.partySprites.babyt.sprite, "roar"),
				MessageBox{message="Baby T: Enjoy your final moments Robuttnik, cause Tails is gonna wish you gone for good!!"}
			},
			Animate(scene.partySprites.babyt.sprite, "idle"),
			MessageBox{message="Robotnik: He he he{p60}, a lovely dream... {p60}but dear boy, surely you are aware of the Light's limitations?...", textSpeed=3},
			MessageBox{message="Robotnik: You can not wish to destroy me, or my empire... {p60}the Light forbids such wishes...", textSpeed=3},
			Parallel {
				scene.partySprites.babyt:hop(),
				MessageBox{message="Baby T: Maybe so! {p60}But he can still wish to change history so that you never took over!"}
			},
			Wait(1),
			Animate(scene.partySprites.tails.sprite, "saddown"),
			MessageBox{message="Tails: ..."},
			MessageBox{message="Robotnik: It seems that your little friend here is having second thoughts about that plan{p60}, he he he...", textSpeed=3},
			AudioFade("music", 1, 0, 1),
			MessageBox{message="Robotnik: ...while I would love to stay and help you work through this difficult decision, I really must be going...", textSpeed=3},
			Do(function() scene.objectLookup.Robotnik.sprite:setAnimation("throw") end),
			Parallel {
				Ease(scene.objectLookup.Robotnik, "y", function() return scene.objectLookup.Robotnik.y - 80 end, 4),
				MessageBox{message="Robotnik: ...after all, {p60}I have my own wish to make!"}
			},
			Do(function() scene.objectLookup.Robotnik.sprite:setAnimation("flyforward") end),
			Ease(scene.objectLookup.Robotnik, "y", function() return scene.objectLookup.Robotnik.y + 30 end, 1),
			Ease(scene.objectLookup.Robotnik, "y", function() return scene.objectLookup.Robotnik.y - 500 end, 3),
			Animate(scene.partySprites.babyt.sprite, "idleup"),
			Animate(scene.partySprites.b.sprite, "idleup"),
			Animate(scene.partySprites.tails.sprite, "idleup"),
			Parallel {
				scene.partySprites.b:hop(),
				MessageBox{message="B: He's heading for the Light! {p60}Go Tails!!"}
			},
			Do(function()
				scene.partySprites.tails.sprite:setAnimation("flyup")
				scene.partySprites.tails.sprite.sortOrderY = 10000
			end),
			Ease(scene.partySprites.tails, "y", function() return scene.partySprites.tails.y - 30 end, 2),
			Wait(0.5),
			Ease(scene.partySprites.tails, "y", function() return scene.partySprites.tails.y - 500 end, 3),
		}
	end
	
	return PlayAudio("music", "lightofmobius", 1.0, true, true)
end
