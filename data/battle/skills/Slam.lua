local TargetType = require "util/TargetType"

return {
	name = "Slam",
	target = TargetType.Opponent,
	unusable = function(target)
		return target.side == TargetType.Party or target.aerial
	end,
	cost = 5,
	desc = "Knock opponents into one another",
	action = require "data/battle/skills/actions/Slam"
}