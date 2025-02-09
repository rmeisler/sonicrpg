return function(scene, hint)
	local Transform = require "util/Transform"
	local Rect = unpack(require "util/Shapes")
	local Layout = require "util/Layout"

	local Action = require "actions/Action"
	local TypeText = require "actions/TypeText"
	local Menu = require "actions/Menu"
	local MessageBox = require "actions/MessageBox"
	local PlayAudio = require "actions/PlayAudio"
	local AudioFade = require "actions/AudioFade"
	local Ease = require "actions/Ease"
	local Parallel = require "actions/Parallel"
	local Serial = require "actions/Serial"
	local Wait = require "actions/Wait"
	local Repeat = require "actions/Repeat"
	local Spawn = require "actions/Spawn"
	local Do = require "actions/Do"
	local Animate = require "actions/Animate"
	local SpriteNode = require "object/SpriteNode"
	local TextNode = require "object/TextNode"
	local BasicNPC = require "object/BasicNPC"
	
	local Move = require "actions/Move"
	local BlockPlayer = require "actions/BlockPlayer"
	local Executor = require "actions/Executor"

	scene.stopSfxOnEnterBattle = function(self)
		print("stop sfx!")
		scene.audio:stopSfx("wind")
	end
	scene:addHandler("onEnterBattle", scene.stopSfxOnEnterBattle, scene)

	if hint == "leavecave" and scene.objectLookup.block then
		scene.objectLookup.block:remove()
	end

	return Parallel {
		PlayAudio("sfx", "wind", 0.5, true, true),
		PlayAudio("music", "snowcap", 1.0, true, true)
	}
end
