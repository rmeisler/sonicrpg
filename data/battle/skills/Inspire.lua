local TargetType = require "util/TargetType"

return {
	name = "Inspire",
	target = TargetType.AllParty,
	cost = 10,
	desc = "Sally gives a rousing speech. +5 sp for party.",
	action = require "data/battle/skills/actions/Inspire"
}