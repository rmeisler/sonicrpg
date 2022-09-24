local TargetType = require "util/TargetType"

return {
	name = "Parry",
	target = TargetType.None,
	cost = 5,
	desc = "Press z to dodge the next attack",
	action = require "data/battle/skills/actions/Parry"
}