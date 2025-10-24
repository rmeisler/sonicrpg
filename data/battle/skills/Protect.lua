local TargetType = require "util/TargetType"

return {
	name = "Protect",
	target = TargetType.Party,
	unusable = function(target)
		return target.side ~= TargetType.Party or target.aerial or target.name == "B"
	end,
	cost = 1,
	desc = "Step in front of a party member when attacked.",
	action = require "data/battle/skills/actions/Protect"
}