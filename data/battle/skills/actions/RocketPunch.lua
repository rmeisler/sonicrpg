local Serial = require "actions/Serial"
local Parallel = require "actions/Parallel"
local Wait = require "actions/Wait"
local Ease = require "actions/Ease"
local Animate = require "actions/Animate"
local PlayAudio = require "actions/PlayAudio"
local WaitForFrame = require "actions/WaitForFrame"
local MessageBox = require "actions/MessageBox"
local PlayAudio = require "actions/PlayAudio"
local Do = require "actions/Do"

local PressX = require "data/battle/actions/PressX"
local OnHitEvent = require "data/battle/actions/OnHitEvent"

local SpriteNode = require "object/SpriteNode"

local Layout = require "util/Layout"
local Transform = require "util/Transform"

return function(self, target)
	local origLocation = {x=self.sprite.transform.x, y=self.sprite.transform.y}
	return Serial {
		Animate(self.sprite, "fly1"),
		Do(function()
			self.sprite:setAnimation("fly2")
		end),
		Parallel {
			Ease(self.sprite.transform, "x", target.sprite.transform.x, 4, "quad"),
			Ease(self.sprite.transform, "y", target.sprite.transform.y, 4, "quad")
		},
		
		Parallel {
			target:takeDamage({attack = self.stats.attack * 2, speed = self.stats.speed, luck = self.stats.luck}), 
			Ease(self.sprite.transform, "x", -100, 8, "quad")
		},
		
		Do(function()
			self.sprite.transform.x = 900
		end),
		
		Parallel {
			Ease(self.sprite.transform, "x", origLocation.x, 3, "log"),
			Ease(self.sprite.transform, "y", origLocation.y, 3, "log")
		},
		Animate(self.sprite, "fly1"),
		Animate(self.sprite, "fly3"),
		Do(function()
			self.sprite:setAnimation("idle")
		end)
	}
end
