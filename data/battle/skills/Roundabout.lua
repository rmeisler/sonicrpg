local TargetType = require "util/TargetType"

return {
	name = "Roundabout",
	target = TargetType.Opponent,
	unusable = function(target)
		return target.side == TargetType.Party
	end,
	cost = 3,
	desc = "Confuses enemy.",
	action = require "data/battle/skills/actions/Roundabout"
}