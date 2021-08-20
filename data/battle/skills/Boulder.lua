local TargetType = require "util/TargetType"

return {
	name = "Boulder",
	target = TargetType.AllOpponents,
	unusable = function(target)
		return target.side == TargetType.Party
	end,
	cost = 4,
	desc = "Damages multiple enemies.",
	action = require "data/battle/skills/actions/Boulder"
}