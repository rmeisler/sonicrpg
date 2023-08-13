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
	scene.camPos.x = -14000
	scene.camPos.y = -7000
	return BlockPlayer {
		Wait(1),
		PlayAudio("music", "lupusremix", 1.0, true, true),
		Wait(1),
		MessageBox{message="Sonic: I'll tell ya what... {p120}If you can make it through my obstacle course, I'll give you my way past cool {h scarf}!"},
		Parallel {
			Serial {
				Wait(3),
				Do(function()
					scene.player.blocked = false
				end)
			},
			Ease(scene.camPos, "x", -100, 0.2),
			Ease(scene.camPos, "y", -50, 0.2)
		},
		PlayAudio("sfx", "sonicrunturn", 1.0, true),
		Do(function()
			scene.objectLookup.Sonic:remove()
		end)
	}
end
