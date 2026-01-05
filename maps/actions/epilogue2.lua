local Transform = require "util/Transform"
local Rect = unpack(require "util/Shapes")
local Layout = require "util/Layout"

local Action = require "actions/Action"
local Animate = require "actions/Animate"
local TypeText = require "actions/TypeText"
local Menu = require "actions/Menu"
local MessageBox = require "actions/MessageBox"
local WaitForFrame = require "actions/WaitForFrame"
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
local AudioFade = require "actions/AudioFade"
local Repeat = require "actions/Repeat"
local BlockPlayer = require "actions/BlockPlayer"

local BasicNPC = require "object/BasicNPC"
local EscapeObstacle = require "object/EscapeObstacle"
local EscapeHoverbot = require "object/EscapeHoverbot"
local EscapeIndicator = require "object/EscapeIndicator"

local SpriteNode = require "object/SpriteNode"
local BasicNPC = require "object/BasicNPC"
local EscapePlayer = require "object/EscapePlayer"


return function(scene)
	scene.player.sprite.visible = false
	scene.player.dropShadow.hidden = true

	return BlockPlayer {
		Do(function()
			scene.player.sprite.visible = false
			scene.player.dropShadow.hidden = true
		end),
		Wait(2),
		Ease(scene.camPos, "x", 200, 0.2),
		Do(function()
			scene.objectLookup.Terrabot.sprite:setFadeWhite(0.5)
		end),
		Animate(scene.objectLookup.BabyT.sprite, "shock"),
		scene.objectLookup.BabyT:hop(),
		Do(function()
			scene.objectLookup.UncleT.hidden = false
			scene.objectLookup.UncleT.sprite:setFadeWhite(4)
		end),
		Wait(1),
		Do(function()
			scene.objectLookup.Terrabot:remove()
			scene.objectLookup.UncleT.sprite:setFadeWhite(-1, 1)
		end),
		Wait(2),
		Animate(scene.objectLookup.BabyT.sprite, "joyleft"),
		scene.objectLookup.BabyT:hop(),
		Wait(2),
		Parallel {
			Animate(scene.objectLookup.UncleT.sprite, "unclet_headbutt"),
			Ease(scene.objectLookup.UncleT, "x", function() return scene.objectLookup.UncleT.x + 20 end, 1),
			Serial {
				Wait(0.2),
				Animate(scene.objectLookup.BabyT.sprite, "headbuttleft"),
				Ease(scene.objectLookup.BabyT, "x", function() return scene.objectLookup.BabyT.x - 20 end, 1)
			}
		},
		Wait(2),
		Animate(scene.objectLookup.UncleT.sprite, "unclet"),
		Animate(scene.objectLookup.BabyT.sprite, "joyright"),
		Ease(scene.camPos, "x", 0, 0.2),
		Wait(1),
		Do(function()
			scene:changeScene{map="knothole_ep5", fadeInSpeed=0.2, fadeOutSpeed=0.2, fadeWhite=true, fadeOutMusic=true, hint="ep5_epilogue", spawnPoint="EpilogueSpawn"}
		end)
	}
end
