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
local Telegraph = require "data/monsters/actions/Telegraph"

local SpriteNode = require "object/SpriteNode"
local Transform = require "util/Transform"
local ItemType = require "util/ItemType"

return function(self, target)
	local snowball = SpriteNode(
		self.scene,
		Transform.from(self.sprite.transform),
		{255,255,255,255},
		"snowball",
		nil,
		nil,
		"ui"
	)
	snowball.transform.ox = snowball.w/2
	snowball.transform.oy = snowball.h/2
	snowball.transform.angle = math.pi / 6
	snowball.transform.x = snowball.transform.x + 29 - snowball.w/2
	snowball.transform.y = snowball.transform.y + 32 - snowball.h/2
	return Serial {
		-- Leap forward while attacking
		Animate(self.sprite, "prethrow"),
		Wait(0.5),

		Do(function()
			snowball.color[4] = 0
		end),
		Animate(self.sprite, "throw"),
		Do(function()
			snowball.color[4] = 255
			snowball.transform.x = snowball.transform.x - self.sprite.w * 1.5
		end),
		Parallel {
			Ease(snowball.transform, "x", target.sprite.transform.x, 3, "linear"),
			Ease(snowball.transform, "y", target.sprite.transform.y, 3, "linear"),
			Ease(snowball.transform, "angle", -math.pi * 3.25, 3, "linear")
		},
		Do(function()
			snowball:remove()
			self.sprite:setAnimation("idle")
		end),

		-- Smack and bounce off
		OnHitEvent(self, target)
	}
end
