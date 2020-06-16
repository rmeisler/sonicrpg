local TargetType = require "util/TargetType"

return {
	name = "Grab",
	target = TargetType.Opponent,
	cost = 5,
	desc = "Prevent enemy from attacking for a few turns",
	action = require "data/battle/skills/actions/Grab"
}