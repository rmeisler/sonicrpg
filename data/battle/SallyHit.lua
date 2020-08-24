local TargetType = require "util/TargetType"

return {
	name = "Attack",
	target = TargetType.Opponent,
	unusable = function(target)
		return target.side == TargetType.Party
	end,
	action = require "data/battle/actions/Kick"
}