local Serial = require "actions/Serial"
local Parallel = require "actions/Parallel"
local Wait = require "actions/Wait"
local Ease = require "actions/Ease"
local Animate = require "actions/Animate"
local PlayAudio = require "actions/PlayAudio"
local WaitForFrame = require "actions/WaitForFrame"
local Do = require "actions/Do"

local PressX = require "data/battle/actions/PressX"
local OnHitEvent = require "data/battle/actions/OnHitEvent"

local SpriteNode = require "object/SpriteNode"
local Transform = require "util/Transform"

return function(self, target)
	local wrench = SpriteNode(
		self.scene,
		Transform.from(self.sprite.transform),
		{255,255,255,255},
		"wrench",
		nil,
		nil,
		"ui"
	)
	wrench.transform.ox = wrench.w/2
	wrench.transform.oy = wrench.h/2
	wrench.transform.angle = math.pi / 6
	wrench.transform.x = wrench.transform.x + 49 - wrench.w/2
	wrench.transform.y = wrench.transform.y + 42 - wrench.h/2
	return Serial {
		-- Leap forward while attacking
		Animate(self.sprite, "prethrow"),
		Wait(0.5),
		
		Animate(self.sprite, "throw", true),
		Parallel {
			Ease(wrench.transform, "x", self.sprite.transform.x + 32 - wrench.w, 7, "linear"),
			Ease(wrench.transform, "y", self.sprite.transform.y - wrench.h, 7, "linear"),
			Ease(wrench.transform, "angle", math.pi / 2, 7, "linear"),
		},
		Parallel {
			Ease(wrench.transform, "x", self.sprite.transform.x - wrench.w * 2, 7, "linear"),
			Ease(wrench.transform, "y", self.sprite.transform.y + 12 - wrench.h, 7, "linear"),
			Ease(wrench.transform, "angle", math.pi / 6, 7, "linear"),
		},
		
		Parallel {
			Ease(wrench.transform, "x", target.sprite.transform.x, 2.5, "linear"),
			Ease(wrench.transform, "y", target.sprite.transform.y, 2.5, "linear"),
			Ease(wrench.transform, "angle", -math.pi * 3.25, 2.5, "linear")
		},
		
		-- Smack and bounce off
		OnHitEvent(
			self,
			target,
			Serial {
				Parallel {
					Ease(wrench.transform, "x", target.sprite.transform.x + 60, 4, "linear"),
					Ease(wrench.transform, "y", target.sprite.transform.y - 60, 4, "linear"),
					Ease(wrench.transform, "sx", 3, 4, "linear"),
					Ease(wrench.transform, "sy", 3, 4, "linear"),
					Ease(wrench.transform, "angle", -math.pi * 3.25 + math.pi, 4, "linear"),
					Ease(wrench.color, 4, 0, 4, "linear"),
					Animate(self.sprite, "idle")
				},
				Do(function()
					wrench:remove()
				end)
			}
		)
	}
end
