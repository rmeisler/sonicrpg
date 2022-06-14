local TargetType = require "util/TargetType"

return {
	name = "Resiliency",
	target = TargetType.None,
	unusable = function(_target)
		return false
	end,
	cost = 10,
	desc = "Antoine gets back up after knockout",
	action = require "data/battle/skills/actions/Resiliency"
}