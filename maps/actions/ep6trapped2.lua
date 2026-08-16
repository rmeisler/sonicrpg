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
		Wait(1),
		scene.objectLookup.Antoine:hop(),
		PlayAudio("sfx", "bang", 1, true),
		Animate(scene.objectLookup.Antoine.sprite, "deadvisor"),
		Wait(1.2),
		
		Ease(scene.camPos, "x", -1150, 0.3),
		
		MessageBox{message="Sally: Ugh! {p60}Where is that hedgehog!?"},
		
		Do(function()
			scene:changeScene{map="greatforest_ep6_intro2_run", fadeInSpeed=0.5, fadeOutSpeed=0.5, fadeOutMusic=true}
		end)
	}
end
