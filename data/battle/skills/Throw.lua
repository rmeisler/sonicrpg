local TargetType = require "util/TargetType"

return {
	name = "Throw",
	target = TargetType.Opponent,
	unusable = function(target)
		return target.side == TargetType.Party
	end,
	cost = 4,
	desc = "Hold x and release at the right time to increase damage",
	action = require "data/battle/skills/actions/Throw"
}