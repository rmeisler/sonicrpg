local TargetType = require "util/TargetType"

return {
	name = "Sabotage",
	target = TargetType.Opponent,
	unusable = function(target)
		return target.side == TargetType.Party
	end,
	cost = 8,
	desc = "Reduce an opponent's defense",
	action = require "data/battle/skills/actions/Sabotage"
}