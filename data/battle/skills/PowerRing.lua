local TargetType = require "util/TargetType"

return {
	name = "Power Ring",
	target = TargetType.AllOpponents,
	unusable = function(target)
		return target.side == TargetType.Party or target.boss or target.bossPart
	end,
	cost = 0,
	desc = "Allows Sonic to dispatch all non-boss bots.",
	action = require "data/battle/skills/actions/PowerRing"
}