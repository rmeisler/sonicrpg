local TargetType = require "util/TargetType"

return {
	name = "Run",
	target = TargetType.None,
	action = require "data/battle/actions/RunAway"
}