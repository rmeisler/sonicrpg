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

	GameState.leader = "sonic"
	scene.player:updateSprite()
	scene.player.commandDirection = "down"
	scene.player.sby = 10
	scene.player.cinematic = true

	return BlockPlayer {
		YieldUntil(function()
			return scene.player.y > scene.objectLookup.Waypoint1.y
		end),
		Do(function()
			scene.player.commandDirection = "right"
			scene.player.sbx = 10
		end),
		YieldUntil(function()
			return scene.player.x > scene.objectLookup.Waypoint2.x
		end),
		Do(function()
			scene.player.commandDirection = "down"
			scene.player.sby = 10
		end),
		YieldUntil(function()
			return scene.player.y > scene.objectLookup.Waypoint3.y
		end),
		Do(function()
			scene.player.commandDirection = "left"
			scene.player.sbx = -10
		end),
		YieldUntil(function()
			return scene.player.x < scene.objectLookup.Waypoint4.x
		end),
		Do(function()
			scene.player.commandDirection = "down"
			scene.player.sby = 10
		end),
		YieldUntil(function()
			return scene.player.y > scene.objectLookup.Waypoint5.y
		end),
		Do(function()
			scene.player.specialUpdate = scene.player.basicUpdate
			scene.player.basicUpdate = scene.player.updateFun
			scene.player.x = scene.objectLookup.Waypoint6.x
			scene.player.y = scene.objectLookup.Waypoint6.y
			scene.player.state = "hideup"
		end),
		Wait(2),
		Do(function()
			scene.objectLookup.Cheetah.hidden = false
		end),
		PlayAudio("sfx", "cheetarun", 1, true),
		Ease(scene.objectLookup.Cheetah, "y", scene.objectLookup.CheetahWaypoint.y, 15, "linear"),
		Do(function()
			scene.objectLookup.Cheetah.sprite:setAnimation("idledown")
		end),
		Wait(3),
		Do(function()
			scene.objectLookup.Cheetah.sprite:setAnimation("rundown")
		end),
		Wait(1),
		PlayAudio("sfx", "cheetarun", 1, true),
		Ease(scene.objectLookup.Cheetah, "y", scene.objectLookup.Waypoint4.y, 15, "linear"),
		Wait(0.5),
		Do(function()
			scene.player.state = "peekup"
		end),
		Wait(2),
		Do(function()
			scene.objectLookup.Cheetah.x = scene.objectLookup.CheetahWaypoint2.x
			scene.objectLookup.Cheetah.y = scene.objectLookup.CheetahWaypoint2.y
			scene.objectLookup.Cheetah.sprite:setAnimation("runleft")
		end),
		Ease(scene.objectLookup.Cheetah, "x", scene.objectLookup.CheetahWaypoint3.x, 15, "linear"),
		Do(function()
			scene.objectLookup.Cheetah.sprite:setAnimation("idleleft")
		end),
		Do(function()
			scene.player.state = "shock"
		end),
		
		scene.player:hop(),
		Wait(1.5),
		Do(function()
			scene.player.commandDirection = "down"
			scene.player.state = "juicedown"
			scene.player.sby = 10
			scene.player.basicUpdate = scene.player.specialUpdate
			scene.player.ignoreSpecialMoveCollision = true
		end),
		
		Wait(3),
		Do(function()
			scene.player.sprite.visible = false
			scene.player.dropShadow.hidden = true
			scene:changeScene{map="run3", fadeInSpeed=1, fadeOutSpeed=0.2, enterDelay=1, fadeOutMusic=true}
		end)
	}
end
