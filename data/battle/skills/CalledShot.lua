local TargetType = require "util/TargetType"

return {
	name = "Called Shot",
	target = TargetType.Opponent,
	unusable = function(target)
		return target.side == TargetType.Party
	end,
	cost = 1,
	desc = "Hit the target on the opponent for massive damage!",
	action = require "data/battle/skills/actions/CalledShot"
}