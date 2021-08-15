return function(scene)
	local Transform = require "util/Transform"
	local Rect = unpack(require "util/Shapes")
	local Layout = require "util/Layout"

	local Action = require "actions/Action"
	local TypeText = require "actions/TypeText"
	local Menu = require "actions/Menu"
	local MessageBox = require "actions/MessageBox"
	local PlayAudio = require "actions/PlayAudio"
	local Ease = require "actions/Ease"
	local Parallel = require "actions/Parallel"
	local Serial = require "actions/Serial"
	local Wait = require "actions/Wait"
	local While = require "actions/While"
	local Repeat = require "actions/Repeat"
	local Spawn = require "actions/Spawn"
	local BlockPlayer = require "actions/BlockPlayer"
	local Move = require "actions/Move"
	local Do = require "actions/Do"
	local Animate = require "actions/Animate"
	local shine = require "lib/shine"

	scene.player.collisionHSOffsets = {
		right_top = {x = 0, y = 0},
		right_bot = {x = 0, y = 0},
		left_top = {x = 0, y = 0},
		left_bot = {x = 0, y = 0},
	}
	
	if GameState:isFlagSet("ep2boss") then
	    local mainframe = scene.objectLookup.MainframeComputer
	    scene.player.hidekeyhints[tostring(mainframe)] = mainframe
		scene.camPos.x = 0
		scene.player.sprite.visible = false
		scene.player.dropShadow.sprite.visible = false
		scene.audio:stopMusic()
		return Action()
	end
	
	local stepAction = function()
		scene.juggerbotstepVolume = 0.3
		return Serial {
			PlayAudio("sfx", "juggerbotstep", scene.juggerbotstepVolume, true),
			scene:screenShake(20, 40),
			Wait(1),
			PlayAudio("sfx", "juggerbotstep", scene.juggerbotstepVolume, true),
			scene:screenShake(20, 40)
		}
	end

	-- Continuous stepping sounds from Juggerbot in bg
	scene:run(Spawn(
		While(
			function()
				return not GameState:isFlagSet("ep2boss")
		    end,
			Repeat(Serial {
				stepAction(),
				Wait(5)
			}),
			Action()
		)
	))
	
	return Action()
end
