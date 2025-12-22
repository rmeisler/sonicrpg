local TargetType = require "util/TargetType"

return {
	name = "Super Support",
	target = TargetType.AllParty,
	cost = 6,
	desc = "Baby T says something supportive. +400 hp for party.",
	action = require "data/battle/skills/actions/SuperSupport"
}