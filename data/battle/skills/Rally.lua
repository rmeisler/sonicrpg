local TargetType = require "util/TargetType"

return {
	name = "Rally",
	target = TargetType.AllParty,
	cost = 3,
	desc = "Sally gives a rousing speech. +200 hp for party.",
	action = require "data/battle/skills/actions/Rally"
}