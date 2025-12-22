local TargetType = require "util/TargetType"

return {
	name = "Support",
	target = TargetType.Party,
	cost = 3,
	desc = "Baby T says something supportive. +400 hp for ally.",
	action = require "data/battle/skills/actions/Support"
}