local TargetType = require "util/TargetType"

return {
	name = "Run Away",
	target = TargetType.Opponent,
	unusable = function(target)
		return target.side == TargetType.Party
	end,
	cost = 5,
	desc = "Causes Antoine and bot to leave battle.",
	action = require "data/battle/skills/actions/Run"
}