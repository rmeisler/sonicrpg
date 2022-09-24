local TargetType = require "util/TargetType"

return {
	name = "Cook",
	target = TargetType.None,
	cost = 3,
	desc = "Produces one random food item.",
	action = require "data/battle/skills/actions/Cook"
}