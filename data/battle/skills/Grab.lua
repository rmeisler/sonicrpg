local TargetType = require "util/TargetType"

return {
	name = "Grab",
	target = TargetType.Opponent,
	unusable = function(target)
		return target.side == TargetType.Party
	end,
	cost = 2,
	desc = "Prevent enemy from attacking for a few turns.",
	action = require "data/battle/skills/actions/Grab"
}