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
		Ease(scene.camPos, "y", 0, 0.2),
		Wait(1),
		PlayAudio("music", "btheme", 1.0, true),
		MessageBox{message="Sally: So... {p60}whaddya think?", closeAction=Wait(3)},
		PlayAudio("music", "btheme", 1.0, true),
		Animate(scene.objectLookup.B.sprite, "seriousdown"),
		MessageBox{message="B: It's more beautiful than I could have ever imagined...", closeAction=Wait(3)},
		Animate(scene.objectLookup.Sally.sprite, "thinking2"),
		MessageBox{message="Sally: Do you feel safe bringing the rest of your family here?", closeAction=Wait(3)},
		Animate(scene.objectLookup.B.sprite, "idledown"),
		MessageBox{message="B: Oh yes--{p60} I would like to help them relocate as soon as possible.", closeAction=Wait(3)},
		Animate(scene.objectLookup.Sally.sprite, "idleleft"),
		MessageBox{message="Sally: Wonderful!{p60} We'll be sure to--", closeAction=Wait(1)},
		Do(function()
			scene.audio:stopMusic()
		end),
		-- Flash twice
		scene:lightningFlash(),
		Wait(0.1),
		scene:lightningFlash(),
		PlayAudio("sfx", "thunder2", 1.0, true),
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
		PlayAudio("sfx", "rain", 1.0, true, true),
		Wait(2.7),
		PlayAudio("music", "ep4intro", 1.0, true),
		-- Lightning strikes
		-- Sally and B look up worried
		-- Rotor comes over
		Animate(scene.objectLookup.B.sprite, "idleright"),
		Animate(scene.objectLookup.Sally.sprite, "idleleft"),
		Wait(2),
		MessageBox{message="Rotor: Sally! {p60}We're getting some wild readings from our weather balloon!", closeAction=Wait(3)},
		MessageBox{message="Rotor: Looks like a major storm is comin' in fast!", closeAction=Wait(3)},
		MessageBox{message="Sally: We'd better get inside, B.", closeAction=Wait(3)},
		-- Transition to scene with Tails seeing lightning in his bed, scared, hiding under sheets
	}
end
