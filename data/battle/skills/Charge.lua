local TargetType = require "util/TargetType"

return {
	name = "Charge",
	target = TargetType.None,
	unusable = function(target)
		return false
	end,
	cost = 3,
	desc = "Ready, aim, charge!",
	action = require "data/battle/skills/actions/Charge"
}