local TargetType = require "util/TargetType"

return {
	name = "Attack",
	target = TargetType.Opponent,
	action = require "data/battle/actions/Kick"
}