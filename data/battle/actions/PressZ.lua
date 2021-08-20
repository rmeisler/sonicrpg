local Action = require "actions/Action"
local Parallel = require "actions/Parallel"
local Animate = require "actions/Animate"
local Try = require "actions/Try"
local Serial = require "actions/Serial"
local Trigger = require "actions/Trigger"

local TargetType = require "util/TargetType"
local SpriteNode = require "object/SpriteNode"

return function(self, target, success, fail)
	-- If opponent v opponent, no press X event
	if (self.side == TargetType.Opponent and target.side == TargetType.Opponent) or
		target.state == self.STATE_IMMOBILIZED
	then
		return fail
	end
	
	return Try(
		Trigger("z", true), -- If they press z too early, fail!
		fail,
		Serial {
			Parallel {
				-- Press Z!
				Animate(function()
					return SpriteNode(self.scene, target.sprite.transform, nil, "pressz", nil, nil, "ui"), true
				end, "idle"),
				
				-- If they press z fast enough, success! Otherwise fail
				Try(
					Trigger("z", true),
					success or Action(),
					fail or Action(),
					0.2
				)
			}
		},
		0.2
	)
end
