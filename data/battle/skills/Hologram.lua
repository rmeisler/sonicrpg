local TargetType = require "util/TargetType"

return {
	name = "Hologram",
	target = TargetType.Party,
	unusable = function(target)
		return table.count(target.scene.party) > 2 or target.side == TargetType.Opponent
	end,
	cost = 5,
	desc = "Create an illusory party member to help absorb aggro",
	action = require "data/battle/skills/actions/Hologram"
}