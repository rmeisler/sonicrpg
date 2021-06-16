local TargetType = require "util/TargetType"

return {
	name = "Rocket Punch",
	target = TargetType.Opponent,
	unusable = function(target)
		return target.side == TargetType.Party
	end,
	cost = 5,
	desc = "Heavy damage to a single enemy.",
	action = require "data/battle/skills/actions/RocketPunch"
}