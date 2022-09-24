local TargetType = require "util/TargetType"

return {
	name = "Spindash",
	target = TargetType.Opponent,
	unusable = function(target)
		return target.side == TargetType.Party or target.aerial
	end,
	cost = 3,
	desc = "Rapidly press x to charge this spin attack.",
	action = require "data/battle/skills/actions/Spindash"
}