local Transform = require "util/Transform"
local Rect = unpack(require "util/Shapes")
local Layout = require "util/Layout"

local Action = require "actions/Action"
local Animate = require "actions/Animate"
local TypeText = require "actions/TypeText"
local Menu = require "actions/Menu"
local MessageBox = require "actions/MessageBox"
local PlayAudio = require "actions/PlayAudio"
local Ease = require "actions/Ease"
local Parallel = require "actions/Parallel"
local Serial = require "actions/Serial"
local Wait = require "actions/Wait"
local While = require "actions/While"
local Move = require "actions/Move"
local Do = require "actions/Do"
local YieldUntil = require "actions/YieldUntil"
local shine = require "lib/shine"
local SpriteNode = require "object/SpriteNode"
local NameScreen = require "actions/NameScreen"
local Executor = require "actions/Executor"
local Spawn = require "actions/Spawn"
local AudioFade = require "actions/AudioFade"
local Repeat = require "actions/Repeat"

local BasicNPC = require "object/BasicNPC"

return function(scene)
    GameState:removeFromParty("antoine")
	
	scene.camPos.y = 1300
	
	local sonicfall = BasicNPC(
		scene,
		{name="objects"},
		{name = "sonicfall", x = 750, y = -120, width = 47, height = 55,
			properties = {
				ghost = true,
				sprite = "art/sprites/sonic.png"
			}
		}
	)
	scene:addObject(sonicfall)

	local sallyfall = BasicNPC(
		scene,
		{name="objects"},
		{name = "sallyfall", x = 870, y = -150, width = 47, height = 55,
			properties = {
				ghost = true,
				sprite = "art/sprites/sally.png"
			}
		}
	)
	scene:addObject(sallyfall)
	
	sonicfall.sprite:setAnimation("shock")
	sallyfall.sprite:setAnimation("shock")
	
	scene.player.sprite.visible = false
	scene.player.dropShadow.sprite.visible = false
	
	return Serial {
		Wait(3),
		
		Parallel {
			Ease(scene.camPos, "y", 0, 0.3, "inout"),
			
			Serial {
				Parallel {
					Ease(sonicfall, "y", 2100, 0.5, "linear"),
					Ease(sallyfall, "y", 2100, 0.5, "linear")
				},
				PlayAudio("sfx", "splash2", 1.0, true)
			}
		},
	
		PlayAudio("music", "mysterious", 1.0, true)
	}
end
