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
	local shine = require "lib/shine"
	local SpriteNode = require "object/SpriteNode"
	local NameScreen = require "actions/NameScreen"
	local Player = require "object/Player"
	
	local text = TypeText(
		Transform(50, 500),
		{255, 255, 255, 0},
		FontCache.Techno,
		"Cave of Light",
		100
	)
	
	if not scene.objectLookup["Golem"] or scene.objectLookup["Golem"]:isRemoved() then
		local layer = scene:findLayer("above2")
		layer.opacity = 0
	end

	return Spawn(Serial {
		Wait(0.5),
		text,
		Ease(text.color, 4, 255, 1),
		PlayAudio("music", "lightofmobius", 1.0, true, true),
		Wait(2),
		Ease(text.color, 4, 0, 1)
	})
end
