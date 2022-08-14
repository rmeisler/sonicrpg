local TargetType = require "util/TargetType"

return {
	name = "Pummel",
	target = TargetType.Opponent,
	unusable = function(target)
		return target.side == TargetType.Party or target.aerial
	end,
	cost = 7,
	desc = "Do several timed attacks for massive damage.",
	action = require "data/battle/skills/actions/Pummel"
}