local TargetType = require "util/TargetType"

return {
	name = "Power Drain",
	target = TargetType.Opponent,
	unusable = function(target)
		return target.side == TargetType.Party
	end,
	cost = 10,
	desc = "Disables bot from doing energy attacks.",
	action = require "data/battle/skills/actions/PowerDrain"
}