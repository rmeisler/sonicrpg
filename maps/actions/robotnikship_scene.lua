return function(scene, hint)
	local Transform = require "util/Transform"
	local Rect = unpack(require "util/Shapes")
	local Layout = require "util/Layout"
	local ItemType = require "util/ItemType"

	local Action = require "actions/Action"
	local TypeText = require "actions/TypeText"
	local Menu = require "actions/Menu"
	local MessageBox = require "actions/MessageBox"
	local Repeat = require "actions/Repeat"
	local PlayAudio = require "actions/PlayAudio"
	local AudioFade = require "actions/AudioFade"
	local Ease = require "actions/Ease"
	local BlockPlayer = require "actions/BlockPlayer"
	local Parallel = require "actions/Parallel"
	local Serial = require "actions/Serial"
	local Move = require "actions/Move"
	local Executor = require "actions/Executor"
	local Wait = require "actions/Wait"
	local Do = require "actions/Do"
	local Spawn = require "actions/Spawn"
	local Animate = require "actions/Animate"
	local shine = require "lib/shine"
	local SpriteNode = require "object/SpriteNode"
	local NameScreen = require "actions/NameScreen"
	local Player = require "object/Player"
	
	scene.player.sprite.visible = false
	scene.player.dropShadow.hidden = true

	return BlockPlayer {
		Do(function()
			scene.player.sprite.visible = false
			scene.player.dropShadow.hidden = true
		end),

		Wait(0.5),

		PlayAudio("sfx", "elevator", 1, true),
		MessageBox{
			message="Swatbot: zzz. {p40}Approaching target coordinates. {p40}ETA 1 hour.",
			closeAction=Wait(2),
			rect=MessageBox.TOP_OF_WINDOW
		},
		Wait(1.5),
		Animate(scene.objectLookup.Robotnik.sprite, "thinking"),
		MessageBox{
			message="Robotnik: Hmm... {p40}this place feels strangely familiar to me...",
			closeAction=Wait(2),
			rect=MessageBox.TOP_OF_WINDOW
		},
		Wait(1),
		Animate(scene.objectLookup.Robotnik.sprite, "idle"),
		MessageBox{
			message="Robotnik: No matter. {p60}Those despicable \"Freedom Fighters\" will pay for the damage they've done to my beautiful {h Project Firebird}...",
			closeAction=Wait(4),
			rect=MessageBox.TOP_OF_WINDOW
		},
		Wait(0.5),
		Animate(scene.objectLookup.Robotnik.sprite, "pose"),
		MessageBox{
			message="Robotnik: ...once my wish is granted, I will have the precise location of {h Knothole Village}...",
			closeAction=Wait(4),
			rect=MessageBox.TOP_OF_WINDOW
		},
		Do(function()
			scene:changeScene{map="boulderbay_meanwhile2", fadeOutSpeed=0.2, fadeInSpeed=0.2, fadeOutMusic=true}
		end)
	}
end
