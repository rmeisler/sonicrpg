local TargetType = require "util/TargetType"

return {
	name = "Scan",
	target = TargetType.Opponent,
	unusable = function(target)
		return target.side == TargetType.Party
	end,
	cost = 1,
	desc = "Run diagnostics on an opponent.",
	action = require "data/battle/skills/actions/LoganScan"
}