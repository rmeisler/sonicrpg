local TargetType = require "util/TargetType"

return {
	name = "Infect",
	target = TargetType.Opponent,
	cost = 7,
	desc = "Sally injects bugs into a bot's software.",
	action = require "data/battle/skills/actions/Infect"
}