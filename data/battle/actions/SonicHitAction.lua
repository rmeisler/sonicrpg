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

local LeapBackward = function(self, target)
	return Serial {
		-- Bounce off target
		Parallel {
			Ease(self.sprite.transform, "y", target.sprite.transform.y - self.sprite.h*2.5, 4, "linear"),
			Ease(self.sprite.transform, "x", target.sprite.transform.x + self.sprite.w*2, 4, "linear"),
		},
		Parallel {
			Ease(self.sprite.transform, "y", target.sprite.transform.y + target.sprite.h - self.sprite.h, 4, "linear"),
			Ease(self.sprite.transform, "x", target.sprite.transform.x + self.sprite.w*3, 4, "linear")
		},
		
		-- Land on ground
		Animate(self.sprite, "crouch"),
		Wait(0.1),
		Animate(self.sprite, "idle"),
		Wait(0.15),

		-- Leap backward
		Animate(self.sprite, "crouch"),
		Wait(0.1),
		Animate(self.sprite, "leap"),
		Parallel {
			Ease(self.sprite.transform, "x", self.sprite.transform.x, 3),
			Serial {
				Ease(self.sprite.transform, "y", self.sprite.transform.y - math.abs(target.sprite.transform.y - self.sprite.transform.y) - self.sprite.h, 4),
				Ease(self.sprite.transform, "y", self.sprite.transform.y, 6)
			}
		},
		
		Animate(self.sprite, "crouch"),
		Wait(0.1),
		Animate(self.sprite, "idle"),
	}
end

return function(self, target)
	return Serial {
		-- Leap forward while attacking
		Animate(self.sprite, "crouch"),
		Wait(0.1),

		Animate(self.sprite, "leap", true),
		Parallel {
			Ease(self.sprite.transform, "x", target.sprite.transform.x + math.abs(target.sprite.transform.x - self.sprite.transform.x)/2, 4, "linear"),
			Ease(self.sprite.transform, "y", self.sprite.transform.y - self.sprite.h*3, 6, "linear"),
		},

		Parallel {
			Ease(self.sprite.transform, "x", target.sprite.transform.x + target.sprite.w, 4, "linear"),
			Serial {
				Wait(0.09),
				Animate(self.sprite, "spin", true),
				Ease(self.sprite.transform, "y", target.sprite.transform.y - self.sprite.h, 6, "linear")
			}
		},
		
		Parallel {
			Animate(function()
				local xform = Transform(
					target.sprite.transform.x,
					target.sprite.transform.y,
					3,
					3
				)
				return SpriteNode(target.scene, xform, nil, "smack", nil, nil, "ui"), true
			end, "idle"),
			
			-- Smack and bounce off
			OnHitEvent(
				self,
				target,
				LeapBackward(self, target)
			)
		}
	}
end