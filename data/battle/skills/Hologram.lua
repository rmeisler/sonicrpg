local TargetType = require "util/TargetType"

return {
	name = "Hologram",
	target = TargetType.None,
	cost = 10,
	desc = "Create an illusory party member to help absorb aggro",
	action = require "data/battle/skills/actions/Hologram"
}