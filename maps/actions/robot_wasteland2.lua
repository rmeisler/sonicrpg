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
	local megamuckLayer1 = scene:findLayer("megamuck1")
	local megamuckLayer2 = scene:findLayer("megamuck2")

	return Serial {
		PlayAudio("sfx", "lightrain", 0.5, true, true),
		PlayAudio("music", "robotwasteland", 1, true, true),

		-- Mud effect
		Spawn(Repeat(Serial {
			Do(function()
				megamuckLayer1.opacity = 0
				megamuckLayer2.opacity = 1
			end),
			Wait(0.2),
			Do(function()
				megamuckLayer1.opacity = 1
				megamuckLayer2.opacity = 0
			end),
			Wait(0.2),
		}))
	}
end
