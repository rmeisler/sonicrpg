local TargetType = require "util/TargetType"

return {
	name = "EMP",
	target = TargetType.AllOpponents,
	cost = 7,
	desc = "Disables all bots for one turn.",
	action = require "data/battle/skills/actions/EMP"
}