local TargetType = require "util/TargetType"

return {
	name = "Bounce",
	target = TargetType.Opponent,
	cost = 7,
	desc = "Press x to repeatedly damage enemy.",
	action = require "data/battle/skills/actions/Bounce"
}