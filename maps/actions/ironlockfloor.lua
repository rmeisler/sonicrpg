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
	
	local subtext = TypeText(
		Transform(50, 470),
		{255, 255, 255, 0},
		FontCache.TechnoSmall,
		"Iron Lock",
		100
	)
	
	local text = TypeText(
		Transform(50, 500),
		{255, 255, 255, 0},
		FontCache.Techno,
		scene.map.properties.sectorName,
		100
	)
	
	local showTitle = function()
		Executor(scene):act(Serial {
			Wait(0.5),
			subtext,
			text,
			Parallel {
				Ease(subtext.color, 4, 255, 1),
			    Ease(text.color, 4, 255, 1)
			},
			Wait(2),
			Parallel {
				Ease(subtext.color, 4, 0, 1),
			    Ease(text.color, 4, 0, 1)
			}
		})
	end
	
	if hint == "thirdfloor" then
		showTitle()
		scene.player.sprite.visible = false
		scene.player.dropShadow.hidden = true
		return BlockPlayer {
			Do(function()
				scene.player.sprite.visible = false
				scene.player.dropShadow.hidden = true
			end),
			Wait(2),
			Parallel {
				Ease(scene.objectLookup.Sonic, "y", scene.player.y - 98, 3, "linear"),
				Ease(scene.objectLookup.Sally, "y", scene.player.y + 60 - 98, 3, "linear"),
				Ease(scene.objectLookup.Antoine, "y", scene.player.y - 98, 3, "linear")
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
	
	showTitle()
	return PlayAudio("music", "ironlock", 1.0, true, true)
end
