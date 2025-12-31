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

return function(self, target)
	if target == nil then
		return Telegraph(self, "No targets available", {500,500,500,50})
	end

	local origXForm = Transform.from(self.sprite.transform)

	return Serial {
		-- Leap forward while attacking
		Animate(self.sprite, "redcrouchright"),
		Wait(0.1),

		Animate(self.sprite, "redleapright"),
		Parallel {
			Ease(self.sprite.transform, "x", target.sprite.transform.x - math.abs(target.sprite.transform.x - self.sprite.transform.x)/2, 4, "linear"),
			Ease(self.sprite.transform, "y", self.sprite.transform.y - self.sprite.h*3, 6, "linear"),
		},
		Do(function()
			self.sprite.sortOrderY = target.sprite.transform.y + target.sprite.h/2
		end),

		Parallel {
			Ease(self.sprite.transform, "x", target.sprite.transform.x - target.sprite.w, 4, "linear"),
			Serial {
				Wait(0.09),
				Ease(self.sprite.transform, "y", target.sprite.transform.y + target.sprite.h - self.sprite.h, 6, "linear")
			}
		},

		-- Land on ground
		Animate(self.sprite, "redcrouchright"),
		Wait(0.15),

		-- Upper cut
		Animate(self.sprite, "redjumpright"),
		Parallel {
			Serial {
				Parallel {
					Ease(self.sprite.transform, "x", function() return self.sprite.transform.x + 20 end, 3),
					Ease(self.sprite.transform, "y", function() return self.sprite.transform.y - 100 end, 4)
				},
				Parallel {
					Ease(self.sprite.transform, "x", function() return self.sprite.transform.x + 80 end, 3),
					Ease(self.sprite.transform, "y", target.sprite.transform.y + target.sprite.h - self.sprite.h, 4)
				},
				Animate(self.sprite, "redcrouchright")
			},

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
			target:takeDamage(self.stats)
		},
		
		-- Leap backward
		Animate(self.sprite, "redcrouchright"),
		Wait(0.1),
		Animate(self.sprite, "redleapright"),
		Parallel {
			Ease(self.sprite.transform, "x", origXForm.x, 3),
			Serial {
				Ease(self.sprite.transform, "y", origXForm.y - math.abs(target.sprite.transform.y - origXForm.y) - self.sprite.h, 4),
				Do(function()
					self.sprite.sortOrderY = self.sprite.transform.y + self.sprite.h
				end),
				Ease(self.sprite.transform, "y", origXForm.y, 6)
			}
		},
		
		Animate(self.sprite, "redcrouchright"),
		Wait(0.1),
		Animate(self.sprite, "redidle")
	}
end