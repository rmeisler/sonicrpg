local TargetType = require "util/TargetType"

return {
	name = "Super Mine",
	target = TargetType.Opponent,
	unusable = function(target)
		return target.side == TargetType.Party
	end,
	cost = 20,
	desc = "Choose the direction, splash, and detonation as you throw",
	action = require "data/battle/skills/actions/SuperMine"
}