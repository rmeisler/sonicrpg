local TargetType = require "util/TargetType"

return {
	name = "Power Ring",
	target = TargetType.Opponent,
	cost = 0,
	desc = "Multiplies all stats by 2!",
	action = require "data/battle/skills/actions/PowerRing"
}