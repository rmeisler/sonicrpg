local TargetType = require "util/TargetType"

return {
	name = "Interrupt+",
	target = TargetType.Opponent,
	unusable = function(target)
		return target.side == TargetType.Party or target.name == "Phantom"
	end,
	cost = 1,
	desc = "Trigger a hardware interrupt. Bot loses 3 turns.",
	action = require "data/battle/skills/actions/Interrupt2"
}