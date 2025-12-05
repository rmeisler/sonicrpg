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
	
	local waterfallLayer1 = scene:findLayer("waterfall1")
	local waterfallLayer2 = scene:findLayer("waterfall2")
	local floor2Layer = scene:findLayer("floor2")
	local waterfallAnim = Spawn(
		Repeat(Serial {
			Do(function()
				waterfallLayer1.opacity = 0.7
				waterfallLayer2.opacity = 0
				floor2Layer.opacity = 0
			end),
			Wait(0.2),
			Do(function()
				waterfallLayer1.opacity = 0
				waterfallLayer2.opacity = 0.7
				floor2Layer.opacity = 1
			end),
			Wait(0.2),
		}, 1000000)
	)

	return Serial {
		Do(function() scene.player.noSpecialMove = true end),
		PlayAudio("music", "mysterious", 1.0, true, true),
		waterfallAnim
	}
end
