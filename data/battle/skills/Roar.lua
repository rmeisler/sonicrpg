local TargetType = require "util/TargetType"

return {
	name = "Roar",
	target = TargetType.AllOpponents,
	unusable = function(target)
		return target.side == TargetType.Party
	end,
	cost = 8,
	desc = "Scares opponents, reducing their defenses",
	action = require "data/battle/skills/actions/Roar"
}