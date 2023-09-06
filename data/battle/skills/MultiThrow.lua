local TargetType = require "util/TargetType"

return {
	name = "Multi-Throw",
	target = TargetType.AllOpponents,
	unusable = function(target)
		return target.side == TargetType.Party
	end,
	cost = 12,
	desc = "Rapidly press x, then z, then x, etc",
	action = require "data/battle/skills/actions/MultiThrow"
}