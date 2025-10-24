local TargetType = require "util/TargetType"

return {
	name = "Encourage",
	target = TargetType.AllParty,
	cost = 5,
	desc = "B gives an encouraging speech. +3 sp for party.",
	action = require "data/battle/skills/actions/Encourage"
}