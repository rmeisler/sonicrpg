local TargetType = require "util/TargetType"

return {
	name = "Predict",
	target = TargetType.None,
	cost = 10,
	desc = "Increases Logan's chance to evade attacks",
	action = require "data/battle/skills/actions/Predict"
}