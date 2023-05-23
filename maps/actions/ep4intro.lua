return function(scene)
	local Transform = require "util/Transform"
	local Rect = unpack(require "util/Shapes")
	local Layout = require "util/Layout"

	local Action = require "actions/Action"
	local TypeText = require "actions/TypeText"
	local Animate = require "actions/Animate"
	local Menu = require "actions/Menu"
	local Move = require "actions/Move"
	local MessageBox = require "actions/MessageBox"
	local PlayAudio = require "actions/PlayAudio"
	local Ease = require "actions/Ease"
	local Parallel = require "actions/Parallel"
	local Serial = require "actions/Serial"
	local BlockPlayer = require "actions/BlockPlayer"
	local Executor = require "actions/Executor"
	local Wait = require "actions/Wait"
	local Do = require "actions/Do"
	local shine = require "lib/shine"
	local SpriteNode = require "object/SpriteNode"
	local NameScreen = require "actions/NameScreen"
	local Player = require "object/Player"
	
	scene.player.dustColor = Player.FOREST_DUST_COLOR

	scene.player.sprite.visible = false
	scene.player.dropShadow.hidden = true

	return BlockPlayer
	{
		Do(function()
			scene.player.sprite.visible = false
			scene.player.dropShadow.hidden = true
			scene.camPos.y = -900
		end),
		Wait(1),
		PlayAudio("music", "ep4harp", 0.3, true),
		Wait(3),
		Parallel {
			MessageBox{message="Sally: So... {p80}whaddya think?", closeAction=Wait(5)},
			Serial {
				Ease(scene.camPos, "y", 0, 0.15),
				Wait(2)
			}
		},
		PlayAudio("music", "btheme", 1.0, true),
		Animate(scene.objectLookup.B.sprite, "seriousdown"),
		PlayAudio("music", "btheme", 1.0, true),
		MessageBox{message="B: It's more beautiful than I could have ever imagined...", closeAction=Wait(3)},
		Animate(scene.objectLookup.Sally.sprite, "thinking2"),
		MessageBox{message="Sally: Do you feel safe bringing the rest of your family here?", closeAction=Wait(3)},
		Animate(scene.objectLookup.B.sprite, "idledown"),
		MessageBox{message="B: Oh yes--{p60} I would like to help them relocate as soon as possible.", closeAction=Wait(3)},
		Animate(scene.objectLookup.Sally.sprite, "idleleft"),
		MessageBox{message="Sally: That's wonderful, B!{p60} We'll be sure to--", closeAction=Wait(1)},
		Do(function()
			scene.audio:stopMusic()
		end),
		-- Flash twice
		scene:lightningFlash(),
		Wait(0.1),
		scene:lightningFlash(),
		PlayAudio("sfx", "thunder2",0.8, true),
		Animate(scene.objectLookup.Sally.sprite, "shock"),
		Parallel
		{
			scene.objectLookup.Sally:hop(),
			scene.objectLookup.B:hop()
		},
		Wait(0.5),
		Do(function()
			for _,layer in pairs(scene.map.layers) do
				if layer.name == "rain" then
					Executor(scene):act(Ease(layer, "opacity", 1.0, 0.3))
					return
				end
			end
		end),
		PlayAudio("sfx", "rain", 0.2, true, true),
		Wait(2.7),
		PlayAudio("music", "ep4intro", 1.0, true),
		Animate(scene.objectLookup.B.sprite, "idleright"),
		Animate(scene.objectLookup.Sally.sprite, "idleleft"),
		Wait(2),
		MessageBox{message="Sally: We'd better get inside.", closeAction=Wait(1.5)},
		PlayAudio("music", "spooky", 0.9, true),
		Do(function()
			scene:changeScene{map="sonicshut", fadeOutSpeed=0.5, fadeInSpeed=0.5, hint="sleep", nighttime=true}
		end),
		-- Transition to scene with Tails seeing lightning in his bed, scared, hiding under sheets
	}
end
