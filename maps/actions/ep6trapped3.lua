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
	local EscapePlayer = require "object/EscapePlayer"

	scene.player.sprite.visible = false
	scene.player.dropShadow.hidden = true

	return BlockPlayer {
		Do(function()
			scene.player.sprite.visible = false
			scene.player.dropShadow.hidden = true
		end),
		PlayAudio("music", "racewithfleet", 1, true),
		Wait(1),
		Parallel {
			Ease(scene.camPos, "x", 2150, 0.07),
			Serial {
				Wait(1),
				MessageBox{message="Tails: Welcome{p40}, one and all...", textSpeed=3, closeAction=Wait(2)},
				MessageBox{message="Tails: ...to the ultimate race{p60}, which will finally answer the question...", textSpeed=3, closeAction=Wait(2.5)},
				MessageBox{message="Tails: ...who is the fastest thing alive?!", textSpeed=3, closeAction=Wait(2.5)}
			}
		},
		Parallel {
			Serial {
				Wait(1.2),
				PlayAudio("sfx", "sonicrun", 1.0, true, false, true),
				Animate(scene.objectLookup.Fleet.sprite, "prepare_race2"),
				Parallel {
					Animate(scene.objectLookup.Sonic.sprite, "chargerun1"),
					Ease(scene.objectLookup.Sonic, "y", function() return scene.objectLookup.Sonic.y - 20 end, 4)
				},
				Do(function() scene.objectLookup.Sonic.sprite:setAnimation("chargerun2") end),
				Wait(1.2),
				Animate(scene.objectLookup.Tails.sprite, "joyright"),
				scene.objectLookup.Tails:hop()
			},
			MessageBox{message="Tails: On your mark...{p60} get set...{p60} GO!!", closeAction=Wait(0.5)}
		},
		Do(function()
			scene.player:addSceneHandler("update", EscapePlayer.update)
			scene.player.x = scene.objectLookup.Sonic.x + scene.player.width
			scene.player.y = scene.objectLookup.Sonic.y + scene.player.height + 20
			scene.player.sprite.visible = true
			scene.player.dropShadow.hidden = false
			scene.player.dustColor = {255,255,255,255}
			scene.player.bx = 10
			scene.objectLookup.Sonic.hidden = true
			scene.camPos.x = 0

			--[[
			scene.objectLookup.R.stopMoving = false
			scene.objectLookup.R.bx = -20
			scene.objectLookup.Sonic:remove()
			]]
		end),

		Wait(100),

		Do(function()
			--scene:changeScene{map="greatforest_ep6_intro1", fadeInSpeed=20, fadeOutSpeed=20, fadeOutMusic=false}
		end)
	}
end
