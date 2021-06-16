local TargetType = require "util/TargetType"

return {
	name = "Reveal",
	target = TargetType.Opponent,
	unusable = function(target)
		return target.side == TargetType.Party
	end,
	cost = 5,
	desc = "Display hp of one enemy for entire battle.",
	action = require "data/battle/skills/actions/Reveal"
}