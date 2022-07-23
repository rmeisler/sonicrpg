return function(scene, hint)
	local Transform = require "util/Transform"
	local Rect = unpack(require "util/Shapes")
	local Layout = require "util/Layout"

	local Action = require "actions/Action"
	local TypeText = require "actions/TypeText"
	local Menu = require "actions/Menu"
	local MessageBox = require "actions/MessageBox"
	local PlayAudio = require "actions/PlayAudio"
	local AudioFade = require "actions/AudioFade"
	local Ease = require "actions/Ease"
	local Parallel = require "actions/Parallel"
	local Serial = require "actions/Serial"
	local Wait = require "actions/Wait"
	local Repeat = require "actions/Repeat"
	local Spawn = require "actions/Spawn"
	local Do = require "actions/Do"
	local Animate = require "actions/Animate"
	local SpriteNode = require "object/SpriteNode"
	local TextNode = require "object/TextNode"
	local BasicNPC = require "object/BasicNPC"
	
	local Move = require "actions/Move"
	local BlockPlayer = require "actions/BlockPlayer"
	local Executor = require "actions/Executor"
	
	scene.player.sprite.color[1] = 150
	scene.player.sprite.color[2] = 150
	scene.player.sprite.color[3] = 150
	
	if GameState:isFlagSet("ep3_antoine") then
		return Do(function() end)
	end
	
	GameState:setFlag("ep3_antoine")
	
	scene.player.sprite.visible = false
	scene.player.dropShadow.hidden = true
	return BlockPlayer {
		Do(function()
			scene.player.sprite.visible = false
			scene.player.dropShadow.hidden = true
		end),
		--PlayAudio("music", "dead", 1.0, true),
		PlayAudio("music", "introspection", 1.0, true),
		Do(function()
			scene.objectLookup.Antoine.sprite:setAnimation("paceright")
		end),
		Ease(scene.objectLookup.Antoine, "x", scene.objectLookup.Antoine.x + 200, 1, "linear"),
		Parallel {
			Repeat(Serial {
				Do(function()
					scene.objectLookup.Antoine.sprite:setAnimation("paceleft")
				end),
				Ease(scene.objectLookup.Antoine, "x", scene.objectLookup.Antoine.x - 200, 0.6, "linear"),
				Do(function()
					scene.objectLookup.Antoine.sprite:setAnimation("paceright")
				end),
				Ease(scene.objectLookup.Antoine, "x", scene.objectLookup.Antoine.x + 200, 0.6, "linear")
			}, 14),
			
			Serial {
				MessageBox{message="Antoine: Alright Antoine, this is fine.", closeAction=Wait(1.5)},
				MessageBox{message="Antoine: Sonic and Sally are captured{p40}, that is that.", closeAction=Wait(1.5)},
				MessageBox{message="Antoine: Leaving them be is no option{p40}, so you must save them. {p40}Save them from over ze dozens of ze Swatbots.", closeAction=Wait(1.5)},
				
				MessageBox{message="Antoine: I shall simply use my mastery of kungfu to defeat them! {p40}Except for ze fact that I do not actually know any kungfu... {p60}zis is just something I say to protect my own skin...", closeAction=Wait(2)},
				
				MessageBox{message="Antoine: So what skills do you have then,\nAntoine Depardieu?", closeAction=Wait(1)},
				MessageBox{message="Antoine: Ah! {p40}I am a very fine chef! {p40}Yes, that is right!", closeAction=Wait(1)},
				MessageBox{message="Antoine: So I will serve them food on ze platter and so I serve ze Swatbots a knuckle sandwhich!!", closeAction=Wait(1)},
				MessageBox{message="Antoine: ...no, this does not make sense. {p40}Bots are made of metal. {p40}I will simply hurt my hand...", closeAction=Wait(1)},
				MessageBox{message="Antoine: So what I'm getting at here is zat I am unskilled, untrained, and completely helpless. {p60}I am ze worst Freedom Fighter and I can not help in any capacity, all I do is get captured and let people down, as I am always doing!!", closeAction=Wait(2), textSpeed=3},
			}
		},
		Animate(scene.objectLookup.Antoine.sprite, "scream"),
		MessageBox{message="Antoine: POURQUOI JE SUIS LE PIRE COMBATTANT DE LA LIBERTE QUI NE PEUT RIEN FAIRE DE BIEN!?"},
		
		Do(function()
			--scene.player.sprite.visible = true
			--scene.player.dropShadow.hidden = false
		end)
	}
end
