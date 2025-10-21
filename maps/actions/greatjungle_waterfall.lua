return function(scene, hint)
	local Transform = require "util/Transform"
	local Rect = unpack(require "util/Shapes")
	local Layout = require "util/Layout"

	local Action = require "actions/Action"
	local TypeText = require "actions/TypeText"
	local Menu = require "actions/Menu"
	local MessageBox = require "actions/MessageBox"
	local PlayAudio = require "actions/PlayAudio"
	local Ease = require "actions/Ease"
	local BlockPlayer = require "actions/BlockPlayer"
	local Parallel = require "actions/Parallel"
	local Serial = require "actions/Serial"
	local Executor = require "actions/Executor"
	local Wait = require "actions/Wait"
	local Do = require "actions/Do"
	local Spawn = require "actions/Spawn"
	local Repeat = require "actions/Repeat"
	local shine = require "lib/shine"
	local SpriteNode = require "object/SpriteNode"
	local NameScreen = require "actions/NameScreen"
	local Player = require "object/Player"
	
	if scene.player then
	    scene.player.dustColor = Player.FOREST_DUST_COLOR
	end

	local waterfallLayer2 = scene:findLayer("waterfall2")
	return Serial {
		Spawn(
			Repeat(Serial {
				Do(function()
					waterfallLayer2.opacity = 0
				end),
				Wait(0.2),
				Do(function()
					waterfallLayer2.opacity = 1
				end),
				Wait(0.2),
			}, 1000000)
		),
		PlayAudio("music", "greatjungle", 0.5, true, true)
	}
end
