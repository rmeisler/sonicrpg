local TargetType = require "util/TargetType"

return {
	name = "Rally",
	target = TargetType.AllParty,
	cost = 5,
	desc = "Sally gives a rousing speech. +400 hp for party.",
	action = require "data/battle/skills/actions/Rally"
}