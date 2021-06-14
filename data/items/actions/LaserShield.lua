local Serial = require "actions/Serial"
local Parallel = require "actions/Parallel"
local Do = require "actions/Do"
local Ease = require "actions/Ease"
local Repeat = require "actions/Repeat"
local Animate = require "actions/Animate"
local Executor = require "actions/Executor"
local Wait = require "actions/Wait"
local PlayAudio = require "actions/PlayAudio"

local HealText = require "data/items/actions/HealText"

local SpriteNode = require "object/SpriteNode"

local Transform = require "util/Transform"

return function(self, target)
	local shield = SpriteNode(
		target.scene,
		Transform.from(self.sprite.transform, Transform()),
		nil,
		"lasershield",
		nil,
		nil,
		"sprites"
	)
	shield.transform.x = shield.transform.x - self.sprite.w
	shield.transform.ox = shield.w/2
	shield.transform.oy = shield.h/2
	shield.color = {512,512,512,0}
	shield.transform.sy = 0
	shield.transform.sx = 2
	
	target.laserShield = shield
	
	return Serial {
		PlayAudio("sfx", "shield", 0.4, true),
		Parallel {
			Ease(shield.color, 1, 255, 5),
			Ease(shield.color, 2, 255, 5),
			Ease(shield.color, 3, 255, 5),
			Ease(shield.color, 4, 255, 5),
			Serial {
				Ease(shield.transform, "sy", 3, 10, "quad"),
				Ease(shield.transform, "sy", 1.5, 10, "quad"),
				Ease(shield.transform, "sy", 2, 10, "quad")
			}
		}
	}
end
