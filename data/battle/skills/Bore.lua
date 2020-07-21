local TargetType = require "util/TargetType"

return {
	name = "Bore",
	target = TargetType.AllOpponents,
	cost = 5,
	desc = "Antoine tells a story. All opponents lose a turn.",
	action = require "data/battle/skills/actions/Bore"
}