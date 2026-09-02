local Transform = require "util/Transform"
local Rect = unpack(require "util/Shapes")
local Layout = require "util/Layout"

local Move = require "actions/Move"
local BlockPlayer = require "actions/BlockPlayer"
local Animate = require "actions/Animate"
local TypeText = require "actions/TypeText"
local Menu = require "actions/Menu"
local MessageBox = require "actions/MessageBox"
local AudioFade = require "actions/AudioFade"
local PlayAudio = require "actions/PlayAudio"
local Ease = require "actions/Ease"
local Parallel = require "actions/Parallel"
local Serial = require "actions/Serial"
local Wait = require "actions/Wait"
local While = require "actions/While"
local Do = require "actions/Do"
local YieldUntil = require "actions/YieldUntil"
local shine = require "lib/shine"
local SpriteNode = require "object/SpriteNode"
local NameScreen = require "actions/NameScreen"
local Executor = require "actions/Executor"
local Spawn = require "actions/Spawn"
local Repeat = require "actions/Repeat"
local Action = require "actions/Action"

local Player = require "object/Player"
local BasicNPC = require "object/BasicNPC"

return function(scene)
	scene.player.collisionHSOffsets = {
		right_top = {x = 0, y = 0},
		right_bot = {x = 0, y = 0},
		left_top = {x = 0, y = 0},
		left_bot = {x = 0, y = 0},
	}
	scene.player.dustColor = Player.ROBOTROPOLIS_DUST_COLOR
	
	local subtext = TypeText(
		Transform(50, 470),
		{255, 255, 255, 0},
		FontCache.TechnoSmall,
		"Swatbot Factory",
		100
	)
	
	local text = TypeText(
		Transform(50, 500),
		{255, 255, 255, 0},
		FontCache.Techno,
		"Access Tunnels",
		100
	)

	if GameState:isFlagSet("ep6_robo_tunnel_intro") then
		return Action()
	end
	
	GameState:setFlag("ep6_robo_tunnel_intro")

	return BlockPlayer {
		Do(function()
			scene.player.sprite.visible = false
			scene.player.dropShadow.hidden = true
		end),
		Wait(2),
		Repeat(Serial {
			PlayAudio("sfx", "clink", 1, true),
			Ease(scene.objectLookup.Grate1, "y", function() return scene.objectLookup.Grate1.y + 5 end, 6),
			Ease(scene.objectLookup.Grate1, "y", function() return scene.objectLookup.Grate1.y - 5 end, 6),
			Ease(scene.objectLookup.Grate1, "y", function() return scene.objectLookup.Grate1.y + 3 end, 8),
			Ease(scene.objectLookup.Grate1, "y", function() return scene.objectLookup.Grate1.y - 3 end, 8),
			Ease(scene.objectLookup.Grate1, "y", function() return scene.objectLookup.Grate1.y + 1 end, 10),
			Ease(scene.objectLookup.Grate1, "y", function() return scene.objectLookup.Grate1.y - 1 end, 10),
			Wait(1)
		}, 2),
		
		PlayAudio("sfx", "poptop", 0.5, true),
		Parallel {
			Ease(scene.objectLookup.Grate1, "x", function() return scene.objectLookup.Grate1.x + 20 end, 6),
			Ease(scene.objectLookup.Grate1, "y", function() return scene.objectLookup.Grate1.y + 110 end, 6)
		},
		PlayAudio("sfx", "bang", 1, true),
		Parallel {
			Serial {
				Ease(scene.objectLookup.Grate1, "y", function() return scene.objectLookup.Grate1.y - 5 end, 8),
				Ease(scene.objectLookup.Grate1, "y", function() return scene.objectLookup.Grate1.y + 5 end, 8),
				Ease(scene.objectLookup.Grate1, "y", function() return scene.objectLookup.Grate1.y - 3 end, 10),
				Ease(scene.objectLookup.Grate1, "y", function() return scene.objectLookup.Grate1.y + 3 end, 10)
			},
			Repeat(Serial {
				Ease(scene.objectLookup.Grate1.sprite.color, 4, 255, 20),
				Ease(scene.objectLookup.Grate1.sprite.color, 4, 0, 20)
			}, 10)
		},
		Do(function()
			scene.objectLookup.Grate1:remove()
			scene.objectLookup.SonicHead.hidden = false
			scene.objectLookup.SonicHead.sprite.color[4] = 0
		end),
		Ease(scene.objectLookup.SonicHead.sprite.color, 4, 255, 1),
		Wait(0.5),
		Animate(scene.objectLookup.SonicHead.sprite, "headleft"),
		Wait(1),
		Animate(scene.objectLookup.SonicHead.sprite, "headright"),
		Wait(1),
		Animate(scene.objectLookup.SonicHead.sprite, "leapdown"),
		Parallel {
			Ease(scene.objectLookup.SonicHead, "y", function() return scene.objectLookup.SonicHead.y + 110 end, 6),
			Ease(scene.player, "y", function() return scene.player.y + 110 end, 6)
		},
		PlayAudio("sfx", "bang", 1, true),
		Animate(scene.objectLookup.SonicHead.sprite, "idledown"),
		Do(function()
			scene.objectLookup.SonicHead:remove()
			scene.player.sprite.visible = true
			scene.player.dropShadow.hidden = false
		end),
		Wait(0.5),

		Spawn(Serial {
			subtext,
			text,
			Parallel {
				Ease(text.color, 4, 255, 1),
				Ease(subtext.color, 4, 255, 1),
			},
			PlayAudio("music", "mysterious", 1, true, true),
			Wait(2),
			Parallel {
				Ease(text.color, 4, 0, 1),
				Ease(subtext.color, 4, 0, 1)
			}
		}),
	}
end
