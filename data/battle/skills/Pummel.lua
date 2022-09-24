local TargetType = require "util/TargetType"

return {
	name = "Pummel",
	target = TargetType.Opponent,
	unusable = function(target)
		return target.side == TargetType.Party or target.aerial
	end,
	cost = 8,
	desc = "Deliver multiple blows by rapidly pressing x!",
	action = require "data/battle/skills/actions/Pummel"
}