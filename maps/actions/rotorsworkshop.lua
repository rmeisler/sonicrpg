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
	local Executor = require "actions/Executor"
	local Wait = require "actions/Wait"
	local Do = require "actions/Do"
	local SpriteNode = require "object/SpriteNode"

	local text = TypeText(
		Transform(50, 400),
		{255, 255, 255, 0},
		FontCache.Techno,
		scene.map.properties.regionName,
		100
	)

	Executor(scene):act(Serial {
		Wait(0.5),
		text,
		Ease(text.color, 4, 255, 1),
		Wait(2),
		Ease(text.color, 4, 0, 1)
	})

	scene.audio:playMusic("doittoit", 1.0)

	return Action()
end
