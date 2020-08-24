local TargetType = require "util/TargetType"

return {
	name = "Bounce",
	target = TargetType.Opponent,
	unusable = function(target)
		return target.side == TargetType.Party
	end,
	cost = 7,
	desc = "Press x to repeatedly damage enemy.",
	action = require "data/battle/skills/actions/Bounce"
}