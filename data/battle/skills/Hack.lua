local TargetType = require "util/TargetType"

return {
	name = "Hack",
	target = TargetType.Opponent,
	cost = 5,
	desc = "Use Nicole to remotely hack a robotic opponent.",
	action = require "data/battle/skills/actions/Hack"
}