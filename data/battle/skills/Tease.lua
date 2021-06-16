local TargetType = require "util/TargetType"

return {
	name = "Tease",
	target = TargetType.Opponent,
	unusable = function(target)
		return target.side == TargetType.Party
	end,
	cost = 3,
	desc = "Draw aggro from one bot for 3 turns.",
	action = require "data/battle/skills/actions/Tease"
}