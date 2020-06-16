local TargetType = require "util/TargetType"

return {
	name = "Laser",
	target = TargetType.AllOpponents,
	cost = 10,
	desc = "Fire an optic laser from Nicole",
	action = require "data/battle/skills/actions/Laser"
}