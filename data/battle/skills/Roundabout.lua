local TargetType = require "util/TargetType"

return {
	name = "Roundabout",
	target = TargetType.Opponent,
	cost = 3,
	desc = "Confuses enemy.",
	action = require "data/battle/skills/actions/Roundabout"
}