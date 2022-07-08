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
	
	local text = TypeText(
		Transform(50, 500),
		{255, 255, 255, 0},
		FontCache.Techno,
		"Iron Lock",
		100
	)
	local showTitle = function()
		Executor(scene):act(Serial {
			Wait(0.5),
			text,
			Ease(text.color, 4, 255, 1),
			Wait(2),
			Ease(text.color, 4, 0, 1)
		})
	end
	
	scene.player.sprite.visible = false
	scene.player.dropShadow.hidden = true
	return BlockPlayer {
		PlayAudio("music", "darkintro", 1.0, true, true),
		Do(function()
			scene.player.sprite.visible = false
			scene.player.dropShadow.hidden = true
			scene.objectLookup.Snively.sprite:setAnimation("walkright")
			scene.objectLookup.Swatbot1.sprite:setAnimation("walkright")
			scene.objectLookup.Swatbot2.sprite:setAnimation("walkright")
			scene.objectLookup.Swatbot3.sprite:setAnimation("walkright")
		end),
		Parallel {
			Do(function()
				scene.player.x = scene.objectLookup.Snively.x
			end),
			Ease(scene.objectLookup.Snively, "x", scene.objectLookup.Snively.x + 1500, 0.15, "linear"),
			Ease(scene.objectLookup.Swatbot1, "x", scene.objectLookup.Swatbot1.x + 1500, 0.15, "linear"),
			Ease(scene.objectLookup.Swatbot2, "x", scene.objectLookup.Swatbot2.x + 1500, 0.15, "linear"),
			Ease(scene.objectLookup.Swatbot3, "x", scene.objectLookup.Swatbot3.x + 1500, 0.15, "linear"),
			Repeat(Serial {
				Wait(0.3),
				PlayAudio("sfx", "swatbotstep", 1.0, true)
			}, 20),
			Ease(scene.objectLookup.Cambot2, "x", scene.objectLookup.Cambot2.x - 1500, 0.15, "linear")
		},
		Do(function()
			scene.objectLookup.Snively.sprite:setAnimation("idleright")
			scene.objectLookup.Swatbot1.sprite:setAnimation("idleright")
			scene.objectLookup.Swatbot2.sprite:setAnimation("idleright")
			scene.objectLookup.Swatbot3.sprite:setAnimation("idleright")
			scene.objectLookup.Cambot2:remove()
		end),
		Wait(0.5),
		Animate(scene.objectLookup.Snively.sprite, "idleright_lookright"),
		MessageBox{message="Snively: Security report."},
		MessageBox{message="Swatbot: zzz. {p60}All clear."},
		Animate(scene.objectLookup.Snively.sprite, "angryright"),
		Ease(scene.objectLookup.Snively, "y", function() return scene.objectLookup.Snively.y - 50 end, 8, "linear"),
		Ease(scene.objectLookup.Snively, "y", function() return scene.objectLookup.Snively.y + 50 end, 8, "linear"),
		MessageBox{message="Snively: Check again!!{p60} This project is at a sensitive stage of development!"},
		Wait(0.5),
		Animate(scene.objectLookup.Snively.sprite, "idleright_lookleft"),
		MessageBox{message="Snively: We can't have any of those filthy Freedom Fighters interfering..."},
		MessageBox{message="Swatbot: Yes sir."},
		Do(function()
			scene.objectLookup.Swatbot4.sprite:setAnimation("walkright")
		end),
		Parallel {
			Ease(scene.objectLookup.Swatbot4, "x", scene.objectLookup.Swatbot4.x + 500, 0.2, "linear"),
			Repeat(Serial {
				Wait(0.3),
				PlayAudio("sfx", "swatbotstep", 1.0, true)
			}, 9),
			Serial {
			    Wait(1.2),
			    MessageBox{message="Snively: {p20}.{p20}.{p20}."}
			}
		},
		Do(function()
			scene.objectLookup.Swatbot4:remove()
		end),
		Do(function()
			scene.objectLookup.Snively.sprite:setAnimation("walkright")
			scene.objectLookup.Swatbot1.sprite:setAnimation("walkright")
			scene.objectLookup.Swatbot2.sprite:setAnimation("walkright")
			scene.objectLookup.Swatbot3.sprite:setAnimation("walkright")
		end),
		Parallel {
			Ease(scene.objectLookup.Snively, "x", function() return scene.objectLookup.Snively.x + 750 end, 0.3, "linear"),
			Ease(scene.objectLookup.Swatbot1, "x", function() return scene.objectLookup.Swatbot1.x + 750 end, 0.3, "linear"),
			Ease(scene.objectLookup.Swatbot2, "x", function() return scene.objectLookup.Swatbot2.x + 750 end, 0.3, "linear"),
			Ease(scene.objectLookup.Swatbot3, "x", function() return scene.objectLookup.Swatbot3.x + 750 end, 0.3, "linear"),
			Repeat(Serial {
				Wait(0.3),
				PlayAudio("sfx", "swatbotstep", 1.0, true)
			}, 10),
			AudioFade("music", 1.0, 0.0, 0.3)
		},
		-- FFs lift up trap door and look left/right
		-- All leap out of door
		Do(function()
			scene.player.sprite.visible = true
			scene.player.dropShadow.hidden = false
			scene.player.state = "idledown"
			showTitle()
			
			scene.objectLookup.Snively:remove()
			scene.objectLookup.Swatbot1:remove()
			scene.objectLookup.Swatbot2:remove()
			scene.objectLookup.Swatbot3:remove()
		end),
		PlayAudio("music", "ironlock", 1.0, true, true)
	}
end
