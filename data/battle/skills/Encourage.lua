local TargetType = require "util/TargetType"

return {
	name = "Encourage",
	target = TargetType.Party,
	unusable = function(target)
		return target.side ~= TargetType.Party or target.state ~= target.STATE_DEAD
	end,
	cost = 5,
	desc = "B gives an encouraging speech. Revives party member.",
	action = require "data/battle/skills/actions/Encourage"
}