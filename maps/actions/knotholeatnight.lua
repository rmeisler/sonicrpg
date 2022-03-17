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
	
	scene.audio:playMusic("knotholeatnight", 0.8, true)
	
	if GameState:isFlagSet("ep3_read") then
		scene.objectLookup.TailsHutWarmWindows:remove()
	end
	
	if not GameState:isFlagSet("ep3_laterthatnight") then
		GameState:setFlag("ep3_laterthatnight")
		local subtext = TypeText(
			Transform(50, 500),
			{255, 255, 255, 0},
			FontCache.TechnoMed,
			"Later that night . . .",
			100
		)
		Executor(scene):act(Serial {
			Wait(0.5),
			subtext,
			Ease(subtext.color, 4, 255, 1),
			Wait(2),
			Ease(subtext.color, 4, 0, 1)
		})
		scene.camPos.y = 400
		return BlockPlayer {
			Wait(5),
			Ease(scene.camPos, "y", 0, 0.3),
			Wait(0.5)
		}
	end
	
	return Action()
end
