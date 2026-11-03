local Transform = require "util/Transform"
local Rect = unpack(require "util/Shapes")
local Layout = require "util/Layout"

local Move = require "actions/Move"
local Action = require "actions/Action"
local Animate = require "actions/Animate"
local TypeText = require "actions/TypeText"
local Menu = require "actions/Menu"
local MessageBox = require "actions/MessageBox"
local AudioFade = require "actions/AudioFade"
local PlayAudio = require "actions/PlayAudio"
local Ease = require "actions/Ease"
local Parallel = require "actions/Parallel"
local Serial = require "actions/Serial"
local Wait = require "actions/Wait"
local While = require "actions/While"
local Do = require "actions/Do"
local YieldUntil = require "actions/YieldUntil"
local shine = require "lib/shine"
local SpriteNode = require "object/SpriteNode"
local NameScreen = require "actions/NameScreen"
local Executor = require "actions/Executor"
local Spawn = require "actions/Spawn"
local Repeat = require "actions/Repeat"
local BlockPlayer = require "actions/BlockPlayer"

local BasicNPC = require "object/BasicNPC"

return function(scene, hint)
	scene.audio:stopMusic()
	scene.audio:stopSfx()
	scene.magnetsOn = true

	local magnetLayer1 = scene:findLayer("magnet1")
	local magnetLayer2 = scene:findLayer("magnet2")

	return Serial {
		PlayAudio("music", "mysterious", 1, true, true),
		PlayAudio("sfx", "magnets", 0.2, true, true),

		-- Magnet effect
		Spawn(Repeat(Serial {
			While(
				function() return scene.magnetsOn end,
				Repeat(
					Serial {
						Do(function()
							magnetLayer1.opacity = 0
							magnetLayer2.opacity = 1
						end),
						Wait(0.2),
						Do(function()
							magnetLayer1.opacity = 1
							magnetLayer2.opacity = 0
						end),
						Wait(0.2),
					}
				),
				Do(function() end)
			),
			YieldUntil(scene, "magnetsOn")
		})),
		
		-- Magnet jitter
		Spawn(Repeat(Serial {
			While(
				function() return scene.magnetsOn end,
				Repeat(
					Serial {
						Do(function()
							magnetLayer1.offsety = magnetLayer1.offsety - 1
							magnetLayer2.offsety = magnetLayer2.offsety - 1
						end),
						Wait(0.01),
						Do(function()
							magnetLayer1.offsety = magnetLayer1.offsety + 1
							magnetLayer2.offsety = magnetLayer2.offsety + 1
						end),
						Wait(0.01),
					}
				),
				Serial {
					Do(function()
						magnetLayer1.opacity = 0
						magnetLayer2.opacity = 0
						scene.audio:stopSfx("magnets")
					end),
					--AudioFade("music", 1, 0, 1)
				}
			),
			YieldUntil(scene, "magnetsOn")
		}))
	}
end
