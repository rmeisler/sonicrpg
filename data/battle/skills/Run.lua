local TargetType = require "util/TargetType"

return {
	name = "Run Away",
	target = TargetType.Opponent,
	unusable = function(target)
		return target.side == TargetType.Party or target.boss or target.bossPart
	end,
	cost = 7,
	desc = "Antoine distracts opponent. Both leave battle.",
	action = require "data/battle/skills/actions/Run"
}