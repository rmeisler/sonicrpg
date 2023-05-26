return function(scene, hint)
	local Transform = require "util/Transform"
	local Rect = unpack(require "util/Shapes")
	local Layout = require "util/Layout"

	local Action = require "actions/Action"
	local Animate = require "actions/Animate"
	local TypeText = require "actions/TypeText"
	local Menu = require "actions/Menu"
	local MessageBox = require "actions/MessageBox"
	local PlayAudio = require "actions/PlayAudio"
	local AudioFade = require "actions/AudioFade"
	local Ease = require "actions/Ease"
	local Repeat = require "actions/Repeat"
	local Parallel = require "actions/Parallel"
	local Serial = require "actions/Serial"
	local Executor = require "actions/Executor"
	local Wait = require "actions/Wait"
	local BlockPlayer = require "actions/BlockPlayer"
	local Do = require "actions/Do"
	local Move = require "actions/Move"
	local shine = require "lib/shine"
	local SpriteNode = require "object/SpriteNode"
	local NameScreen = require "actions/NameScreen"
	local Player = require "object/Player"
	local BasicNPC = require "object/BasicNPC"

	scene.player.dustColor = Player.FOREST_DUST_COLOR

	if GameState:isFlagSet("ep3_read") then
		scene.objectLookup.TailsHutWarmWindows:remove()
	end
	
	if hint == "intro" then
		return BlockPlayer {
			Do(function()
				scene.player:removeKeyHint()
				local door = scene.objectLookup.WorkshopDoor
				scene.player.hidekeyhints[tostring(door)] = door
				scene.audio:stopMusic()
			end),
			Wait(1.5),
			MessageBox{message="Logan: What the..."},
			PlayAudio("music", "snowday", 1.0, true, true),
			Ease(scene.camPos, "y", -950, 0.25),
			Ease(scene.camPos, "x", 5900, 0.1),
			Ease(scene.camPos, "y", 200, 0.2),
			Wait(1.5),
			Parallel {
				Ease(scene.camPos, "x", 0, 1),
				Ease(scene.camPos, "y", 0, 1)
			},
			MessageBox{message="Logan: Ah. {p60}Welp, I'm going back inside."},
			Do(function()
				scene.player.noIdle = false
				scene.player.hidekeyhints = {}
			end)
		}
	end

	scene.audio:playMusic("snowday", 1.0, true)
	return Action()
end
