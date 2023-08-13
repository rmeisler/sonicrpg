local TargetType = require "util/TargetType"

return {
	name = "Throw",
	target = TargetType.Opponent,
	unusable = function(target)
		return target.side == TargetType.Party
	end,
	action = require "data/battle/actions/SnowballThrow"
}