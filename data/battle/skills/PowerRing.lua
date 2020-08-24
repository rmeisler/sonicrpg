local TargetType = require "util/TargetType"

return {
	name = "Power Ring",
	target = TargetType.Opponent,
	unusable = function(target)
		return target.side == TargetType.Party
	end,
	cost = 0,
	desc = "Multiplies all stats by 2!",
	action = require "data/battle/skills/actions/PowerRing"
}