local Serial = require "actions/Serial"
local Parallel = require "actions/Parallel"
local Wait = require "actions/Wait"
local Ease = require "actions/Ease"
local Animate = require "actions/Animate"
local PlayAudio = require "actions/PlayAudio"
local WaitForFrame = require "actions/WaitForFrame"

local OnHitEvent = require "data/battle/actions/OnHitEvent"

local LeapBackward = function(self, target)
	return Serial {
		Animate(self.sprite, "crouch"),
		Ease(self.sprite.transform, "x", target.sprite.transform.x + target.sprite.w - 5, 1),
		
		-- Leap backward
		Animate(self.sprite, "leap"),
		Parallel {
			Ease(self.sprite.transform, "x", self.sprite.transform.x, 3),
			Serial {
				Ease(self.sprite.transform, "y", 100, 4),
				Ease(self.sprite.transform, "y", self.sprite.transform.y, 6)
			}
		},
			
		Animate(self.sprite, "crouch"),
		Wait(0.2),
		Animate(self.sprite, "idle")
	}
end

return function(self, target)
	return Serial {
		-- Leap forward while attacking
		Animate(self.sprite, "crouch"),
		Wait(0.5),
		Parallel {
			Ease(self.sprite.transform, "x", target.sprite.transform.x + target.sprite.w, 2),
			Serial {
				Animate(self.sprite, "leap"),
				Ease(self.sprite.transform, "y", self.sprite.transform.y - self.sprite.h, 3),

				Parallel {
					Ease(self.sprite.transform, "y", target.sprite.transform.y + target.sprite.h - self.sprite.h, 5),
					
					-- Slash!
					Serial {
						Animate(self.sprite, "slash", true),
						WaitForFrame(self.sprite, 4),
						
						PlayAudio("sfx", "slash", nil, true),
						
						OnHitEvent(self, target, LeapBackward(self, target)),
					}
				}
			}
		}
	}
end
