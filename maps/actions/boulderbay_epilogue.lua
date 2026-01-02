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
		Do(function()
			scene.objectLookup.Swatbot1.sprite:setFadeWhite(0.5)
			scene.objectLookup.Swatbot2.sprite:setFadeWhite(0.5)
			scene.objectLookup.Swatbot3.sprite:setFadeWhite(0.5)
			scene.objectLookup.Swatbot4.sprite:setFadeWhite(0.5)
		end),
		Wait(1),
		Parallel {
			Ease(scene.objectLookup.Swatbot1.sprite.color, 4, 0, 1),
			Ease(scene.objectLookup.Swatbot2.sprite.color, 4, 0, 1),
			Ease(scene.objectLookup.Swatbot3.sprite.color, 4, 0, 1),
			Ease(scene.objectLookup.Swatbot4.sprite.color, 4, 0, 1)
		},
		Animate(scene.objectLookup.GrampaT.sprite, "grampat_surprised"),
		Wait(2),
		Do(function()
			scene:changeScene{map="worldmap", fadeInSpeed=1, fadeOutSpeed=1, fadeWhite=true, hint="ep5_epilogue", spawnPoint="BoulderBaySpawn"}
		end)
	}
end
