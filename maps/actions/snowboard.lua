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

	scene.audio:stopMusic()
	scene.player.blocked = true
	scene.camPos.x = -1500
	scene.camPos.y = -2000
	return BlockPlayer {
		Wait(1),
		PlayAudio("music", "snowboard", 1.0, true, true),
		Parallel {
			Ease(scene.camPos, "x", 0, 0.5),
			Ease(scene.camPos, "y", 0, 0.5)
		},
		PlayAudio("sfx", "sonicrunturn", 1.0, true),
		Do(function()
			scene.player.blocked = false
		end)
	}
end
