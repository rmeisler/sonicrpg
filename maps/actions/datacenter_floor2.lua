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
	local shine = require "lib/shine"
	local SpriteNode = require "object/SpriteNode"
	local NameScreen = require "actions/NameScreen"
	
	local subtext = TypeText(
		Transform(50, 470),
		{255, 255, 255, 0},
		FontCache.TechnoSmall,
		"Data Center",
		100
	)
	
	local text = TypeText(
		Transform(50, 500),
		{255, 255, 255, 0},
		FontCache.Techno,
		"2F",
		100
	)
	Executor(scene):act(Serial {
		Wait(0.5),
		subtext,
		text,
		Parallel {
			Ease(text.color, 4, 255, 1),
			Ease(subtext.color, 4, 255, 1),
		},
		Wait(2),
		Parallel {
			Ease(text.color, 4, 0, 1),
			Ease(subtext.color, 4, 0, 1)
		}
	})
	return Action()
end
