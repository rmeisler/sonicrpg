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
		PlayAudio("music", "racewithfleet", 1, true),
		Wait(1),
		Parallel {
			Ease(scene.camPos, "x", 2150, 0.09),
			Serial {
				Wait(0.5),
				MessageBox{message="Tails: Welcome, one and all!", closeAction=Wait(2)},
				MessageBox{message="Tails: To the ultimate race which will finally answer the question--", closeAction=Wait(2.5)},
				MessageBox{message="Tails: Who is the fastest thing alive?!", closeAction=Wait(2.5)}
			}
		},
		Wait(1),
		Animate(scene.objectLookup.Tails.sprite, "joyright"),
		scene.objectLookup.Tails:hop(),
		MessageBox{message="Tails: On your mark--{p120} get set--{p120} go!!", closeAction=Wait(1)},
		Wait(1.2),
		
		Do(function()
			--scene:changeScene{map="greatforest_ep6_intro1", fadeInSpeed=20, fadeOutSpeed=20, fadeOutMusic=false}
		end)
	}
end
