local TargetType = require "util/TargetType"

return {
	name = "Lift",
	target = TargetType.Opponent,
	unusable = function(target) return target.id == "tails" end,
	cost = 3,
	desc = "Pickup party members or opponents.",
	action = require "data/battle/skills/actions/LiftDrop"
}