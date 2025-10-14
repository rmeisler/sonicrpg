local TargetType = require "util/TargetType"

return {
	name = "Ball",
	target = TargetType.None,
	unusable = function(target)
		return false
	end,
	cost = 5,
	desc = "Roll into a defensive ball for 50% reduction in damage",
	action = require "data/battle/skills/actions/Ball"
}