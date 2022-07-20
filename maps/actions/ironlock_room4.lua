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
	
	if GameState:isFlagSet("ep3_epochtails") then
		scene.player.sprite.visible = false
		scene.player.dropShadow.hidden = true
		return BlockPlayer {
			Do(function()
				scene.player.sprite.visible = false
				scene.player.dropShadow.hidden = true
			end),
			Wait(2),
			Parallel {
				Ease(scene.objectLookup.Sonic, "y", 352 - 98, 3, "linear"),
				Ease(scene.objectLookup.Sally, "y", 416 - 98, 3, "linear"),
				Ease(scene.objectLookup.Antoine, "y", 352 - 98, 3, "linear")
			},
			Animate(scene.objectLookup.Sonic.sprite, "dead"),
			Animate(scene.objectLookup.Sally.sprite, "dead"),
			Animate(scene.objectLookup.Antoine.sprite, "dead"),
			Wait(2.5),
			Animate(scene.objectLookup.Sonic.sprite, "idleright"),
			Animate(scene.objectLookup.Sally.sprite, "idleup"),
			Animate(scene.objectLookup.Antoine.sprite, "idleleft"),
			Wait(0.5),
			Do(function()
				scene.objectLookup.Sonic.sprite:setAnimation("walkright")
				scene.objectLookup.Sally.sprite:setAnimation("walkup")
				scene.objectLookup.Antoine.sprite:setAnimation("walkleft")
			end),
			Parallel {
				Ease(scene.objectLookup.Sonic, "x", scene.player.x, 3, "linear"),
				Ease(scene.objectLookup.Antoine, "x", scene.player.x, 3, "linear"),
				Ease(scene.objectLookup.Sally, "y", function() return scene.objectLookup.Sally.y - 80 end, 3, "linear"),
			},
			Do(function()
				scene.objectLookup.Sonic:remove()
				scene.objectLookup.Sally:remove()
				scene.objectLookup.Antoine:remove()
				scene.player.sprite.visible = true
				scene.player.dropShadow.hidden = false
			end)
		}
	end
	
	GameState:setFlag("ep3_epochtails")
	
	scene.player.sprite.visible = false
	scene.player.dropShadow.hidden = true
	return BlockPlayer {
		Do(function()
			scene.player.sprite.visible = false
			scene.player.dropShadow.hidden = true
		end),
		Wait(2),
		Parallel {
			Ease(scene.objectLookup.Sonic, "y", 352 - 98, 3, "linear"),
			Ease(scene.objectLookup.Sally, "y", 416 - 98, 3, "linear"),
			Ease(scene.objectLookup.Antoine, "y", 352 - 98, 3, "linear")
		},
		Animate(scene.objectLookup.Sonic.sprite, "dead"),
		Animate(scene.objectLookup.Sally.sprite, "dead"),
		Animate(scene.objectLookup.Antoine.sprite, "dead"),
		Wait(2.5),
		Ease(scene.objectLookup.Tails.sprite.color, 4, 255, 0.3),
		Animate(scene.objectLookup.Sonic.sprite, "idleup"),
		Animate(scene.objectLookup.Sally.sprite, "idleup"),
		Animate(scene.objectLookup.Antoine.sprite, "idleup"),
		MessageBox{message="Sonic: ...{p60}Tails?"},
		MessageBox{message="Tails: f!#$ off, hedgehog."},
		Animate(scene.objectLookup.Sonic.sprite, "shock"),
		Animate(scene.objectLookup.Sally.sprite, "shock"),
		Animate(scene.objectLookup.Antoine.sprite, "shock"),
		MessageBox{message="Sonic: You kiss your mother with that mouth!?"},
		MessageBox{message="Tails: I don't wanna get into it."},
		Animate(scene.objectLookup.Sonic.sprite, "idleup"),
		Animate(scene.objectLookup.Sally.sprite, "idleup"),
		Animate(scene.objectLookup.Antoine.sprite, "idleup"),
		Parallel {
			MessageBox{message="Tails: Cya later, s!@#head."},
			Serial {
				Ease(scene.objectLookup.Tails.sprite.color, 4, 0, 0.3),
				Do(function() scene.objectLookup.Tails:remove() end)
			}
		},
		Animate(scene.objectLookup.Sonic.sprite, "idleright"),
		Animate(scene.objectLookup.Sally.sprite, "idleup"),
		Animate(scene.objectLookup.Antoine.sprite, "idleleft"),
		MessageBox{message="Sally: Oh my gosh, {p60}I hope that's not what Tails is going to grow up to be like..."},
		MessageBox{message="Sonic: Mondo uncool..."},
		Do(function()
			scene.objectLookup.Sonic.sprite:setAnimation("walkright")
			scene.objectLookup.Sally.sprite:setAnimation("walkup")
			scene.objectLookup.Antoine.sprite:setAnimation("walkleft")
		end),
		Parallel {
			Ease(scene.objectLookup.Sonic, "x", scene.player.x, 3, "linear"),
			Ease(scene.objectLookup.Antoine, "x", scene.player.x, 3, "linear"),
			Ease(scene.objectLookup.Sally, "y", function() return scene.objectLookup.Sally.y - 80 end, 3, "linear"),
		},
		Do(function()
			scene.objectLookup.Sonic:remove()
			scene.objectLookup.Sally:remove()
			scene.objectLookup.Antoine:remove()
			scene.player.sprite.visible = true
			scene.player.dropShadow.hidden = false
		end)
	}
end
