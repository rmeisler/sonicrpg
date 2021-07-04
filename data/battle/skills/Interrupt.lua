local TargetType = require "util/TargetType"

return {
	name = "Interrupt",
	target = TargetType.Opponent,
	unusable = function(target)
		return target.side == TargetType.Party
	end,
	cost = 3,
	desc = "Trigger a hardware interrupt. Bot loses a turn.",
	action = require "data/battle/skills/actions/Interrupt"
}