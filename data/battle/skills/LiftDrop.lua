local TargetType = require "util/TargetType"

return {
	name = "Lift",
	target = TargetType.Opponent,
	unusable = function(target) return false end,
	cost = 5,
	desc = "Pickup party members or opponents.",
	action = require "data/battle/skills/actions/LiftDrop"
}