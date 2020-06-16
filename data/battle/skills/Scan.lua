local TargetType = require "util/TargetType"

return {
	name = "Scan",
	target = TargetType.Opponent,
	cost = 1,
	desc = "Nicole runs diagnostics on an opponent.",
	action = require "data/battle/skills/actions/Scan"
}