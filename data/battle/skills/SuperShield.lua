local TargetType = require "util/TargetType"

return {
	name = "Shield",
	target = TargetType.Party,
	unusable = function(target)
		return target.side == TargetType.Opponent
	end,
	cost = 20,
	desc = "A modified Laser Shield-- press x, z, or c to maintain",
	action = require "data/battle/skills/actions/SuperShield"
}