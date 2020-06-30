local Transform = require "util/Transform"
local Rect = unpack(require "util/Shapes")
local Layout = require "util/Layout"

local Action = require "actions/Action"
local Animate = require "actions/Animate"
local TypeText = require "actions/TypeText"
local Menu = require "actions/Menu"
local MessageBox = require "actions/MessageBox"
local PlayAudio = require "actions/PlayAudio"
local Ease = require "actions/Ease"
local Parallel = require "actions/Parallel"
local Serial = require "actions/Serial"
local Wait = require "actions/Wait"
local While = require "actions/While"
local Move = require "actions/Move"
local Do = require "actions/Do"
local YieldUntil = require "actions/YieldUntil"
local shine = require "lib/shine"
local SpriteNode = require "object/SpriteNode"
local NameScreen = require "actions/NameScreen"
local Executor = require "actions/Executor"
local Spawn = require "actions/Spawn"
local AudioFade = require "actions/AudioFade"
local Repeat = require "actions/Repeat"

local BasicNPC = require "object/BasicNPC"

local TARGET_OFFSET_X = 400

return function(scene)
	scene.player.sprite.visible = false
	scene.player.dropShadow.sprite.visible = false
	scene.player.cinematic = true
	
	local R = scene.objectLookup.R
	R.movespeed = 3

	return Serial {
		Wait(2),
		
		Parallel {
			Move(R, scene.objectLookup.Waypoint1, "walk"),
			Do(function()
				scene.player.x = R.x + 50
				scene.player.y = R.y
			end)
		},
		Animate(R.sprite, "idleup"),
		Parallel {
			Ease(scene.player, "x", 864, 1, "inout"),
			Ease(scene.player, "y", 2688, 1, "inout")
		},
		
		Do(function()
			scene.objectLookup.R:remove()
			scene.player.sprite.visible = true
			scene.player.dropShadow.sprite.visible = true
			scene.player.noIdle = true
			scene.player.state = "walkup"
		end),
		
		Ease(scene.player, "y", 2588, 1.5, "linear"),

		Do(function()
			scene.player.cinematic = false
			scene.player.noIdle = false
			scene.player.state = "idleup"
		end),
	}
end
