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
	if GameState:isFlagSet("forgotten_fans") then
		scene.audio:playSfx("fan", 0.6)
		scene.audio:setLooping("sfx", true)
		return Action()
	end

	scene.player.sprite.visible = false
	scene.player.dropShadow.sprite.visible = false
	scene.player.cinematicStack = scene.player.cinematicStack + 1
	scene.player.cinematic = true
	
	local R = scene.objectLookup.R

	return Serial {
	    Do(function()
		    scene.player.x = R.x
   	        scene.player.y = R.y + 60
		end),
		Wait(1),
		
		Parallel {
			Serial {
				Move(R, scene.objectLookup.Waypoint0, "walk"),
				Animate(R.sprite, "idleup"),
				Wait(0.5),
				Animate(R.sprite, "idledown"),
				Wait(0.5),
				
				Do(function()
					R.movespeed = 15
				end),
				Animate(R.sprite, "pose"),
				Animate(R.sprite, "dashstart"),
				Move(R, scene.objectLookup.Waypoint1, "dash"),
				Move(R, scene.objectLookup.Waypoint2, "dash"),
				Move(R, scene.objectLookup.Waypoint3, "dash"),
				Move(R, scene.objectLookup.Waypoint5, "dash"),
				Move(R, scene.objectLookup.Waypoint6, "dash"),
				Move(R, scene.objectLookup.Waypoint7, "dash"),
				Do(function()
					R.movespeed = 2
				end),
				Move(R, scene.objectLookup.Waypoint8, "walk"),
				Animate(R.sprite, "idledown"),
				Wait(0.5),
				Animate(R.sprite, "idleup"),
				Wait(0.5),
				Do(function()
					scene.objectLookup.Switch1:flip()
					scene.audio:playSfx("fan", 0.6)
					scene.audio:setLooping("sfx", true)
				end),
				Wait(0.5),
				Animate(R.sprite, "idledown"),
				Wait(0.5),
				
				Move(R, scene.objectLookup.Waypoint7, "walk"),
				Animate(R.sprite, "idledown"),
				Wait(0.5),
				
				Animate(R.sprite, "pose"),
				Animate(R.sprite, "dashstart"),
				Do(function()
					R.movespeed = 15
				end),
				
				Move(R, scene.objectLookup.Waypoint9, "dash"),
				Do(function()
					R.sprite.visible = false
				end),
			},
			Do(function()
				scene.player.x = R.x
				scene.player.y = R.y + 60
			end)
		},
		
		Wait(0.5),
		
		Parallel {
			Ease(scene.player, "x", 800, 0.2, "inout"),
			Ease(scene.player, "y", 2688, 0.2, "inout")
		},
		
		Do(function()
			scene.player.sprite.visible = true
			scene.player.dropShadow.sprite.visible = true
			scene.player.noIdle = true
			scene.player.sprite:setAnimation("walkup")
		end),
		
		Ease(scene.player, "y", 2588, 2, "linear"),

		Do(function()
			scene.player.cinematicStack = 0
			scene.player.cinematic = false
			scene.player.noIdle = false
			scene.player.state = "idleup"
			
			GameState:setFlag("forgotten_fans")
		end),
	}
end
