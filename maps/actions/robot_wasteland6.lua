local Transform = require "util/Transform"
local Rect = unpack(require "util/Shapes")
local Layout = require "util/Layout"

local Move = require "actions/Move"
local Action = require "actions/Action"
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
local BlockPlayer = require "actions/BlockPlayer"

local BasicNPC = require "object/BasicNPC"

return function(scene, hint)
	scene.audio:stopMusic()
	scene.audio:stopSfx()

	return BlockPlayer {
		Do(function()
			scene.player.noIdle = true
			scene.player.dropShadow.hidden = true
			scene.player.sprite:setAnimation("dead")
		end),
		
		Wait(4),
		Do(function() scene.player.sprite:setAnimation("kneelleft") end),
		MessageBox{message="Sally: *breathing hard*{p60} That was way too close!"},
		Wait(0.5),
		Animate(scene.objectLookup.Sonic.sprite, "dead3_right"),
		MessageBox{message="Sonic: That Cheetah's not gonna make gettin' outta here any easier... {p60}this leg's gonna have to heal real fast."},
		Wait(0.5),
		Do(function() scene.player.sprite:setAnimation("thinking") end),
		MessageBox{message="Sally: Let's just be thankful that it's now behind 2 feet of solid steel."},
		Wait(0.5),
		MessageBox{message="Sonic: Yeah, for now..."},
		Wait(1),
		Do(function() scene.player.sprite:setAnimation("idleleft") end),
		MessageBox{message="Sally: Wait a second... {p60}where's B?"},
		Wait(0.5),
		MessageBox{message="Sonic: He's gotta be around here somewhere."},
		Parallel {
			Ease(scene.objectLookup.Sonic, "x", scene.player.x - 40, 2),
			Ease(scene.objectLookup.Sonic, "y", scene.player.y - 80, 2)
		},
		Do(function()
			GameState:removeFromParty("b")
			scene.player.noIdle = false
			scene.player.dropShadow.hidden = false
			scene.objectLookup.Sonic:remove()
		end)
	}
end
