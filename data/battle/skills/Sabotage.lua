local TargetType = require "util/TargetType"

return {
	name = "Sabotage",
	target = TargetType.Opponent,
	unusable = function(target)
		return target.side == TargetType.Party
	end,
	cost = 6,
	desc = "Reduce an opponent's attack, defense, or speed",
	action = require "data/battle/skills/actions/Sabotage"
}