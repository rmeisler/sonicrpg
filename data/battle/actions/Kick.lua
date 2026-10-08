local Serial = require "actions/Serial"
local Parallel = require "actions/Parallel"
local Wait = require "actions/Wait"
local Ease = require "actions/Ease"
local Animate = require "actions/Animate"
local PlayAudio = require "actions/PlayAudio"
local WaitForFrame = require "actions/WaitForFrame"
local Do = require "actions/Do"
local Action = require "actions/Action"

local OnHitEvent = require "data/battle/actions/OnHitEvent"

local LeapBackward = function(self, target)
	local hasSallyCounter = self.id == "sally" and GameState.party[self.id].level >= 10
	return Serial {
		hasSallyCounter and Wait(0.5) or Serial {
			Animate(self.sprite, "retract_kick"),
			Animate(self.sprite, "crouch")
		},
		
		Ease(self.sprite.transform, "x", target.sprite.transform.x + target.sprite.w - 5, 1),
		
		-- Leap backward
		Animate(self.sprite, "leap"),
		Parallel {
			Ease(self.sprite.transform, "x", self.sprite.transform.x, 3),
			Serial {
				Ease(self.sprite.transform, "y", target.sprite.transform.y - math.abs(target.sprite.transform.y - self.sprite.transform.y) - self.sprite.h, 4),
				Do(function()
					self.sprite.sortOrderY = self.sprite.transform.y + self.sprite.h
				end),
				Ease(self.sprite.transform, "y", self.sprite.transform.y, 6)
			}
		},
			
		Animate(self.sprite, "crouch"),
		Wait(0.2),
		Animate(self.sprite, "idle")
	}
end

return function(self, target)
	local hasSallyCounter = self.id == "sally" and GameState.party[self.id].level >= 10
	local jumpHeight = hasSallyCounter and 80 or 0
	return Serial {
		-- Leap forward while attacking
		Animate(self.sprite, "crouch"),
		Wait(0.5),
		Parallel {
			Ease(self.sprite.transform, "x", target.sprite.transform.x + target.sprite.w, 2),
			Serial {
				Animate(self.sprite, "leap"),
				Parallel {
					Ease(self.sprite.transform, "y", target.sprite.transform.y - math.abs(target.sprite.transform.y - self.sprite.transform.y) - self.sprite.h - jumpHeight, 4),
					Serial {
						Wait(0.1),
						hasSallyCounter and Animate(self.sprite, "counter_flip") or Action()
					}
				},
				Do(function()
					self.sprite.sortOrderY = target.sprite.transform.y + target.sprite.h/2
				end),
				
				

				Parallel {
					Serial {
						Ease(self.sprite.transform, "y", target.sprite.transform.y + target.sprite.h - self.sprite.h*2, 5),
						Parallel {
							hasSallyCounter and Animate(self.sprite, "counter_land") or Action(),
							Ease(self.sprite.transform, "y", target.sprite.transform.y + target.sprite.h - self.sprite.h, 12, "quad")
						}
					},
					
					-- Slash!
					Serial {
						hasSallyCounter and Action() or Animate(self.sprite, "kick"),
						
						OnHitEvent(self, target, LeapBackward(self, target)),
					}
				}
			}
		}
	}
end
