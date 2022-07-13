local TargetType = require "util/TargetType"

return {
	name = "Inspire",
	target = TargetType.AllParty,
	cost = 10,
	desc = "All party members recover from status effects.",
	action = require "data/battle/skills/actions/Inspire"
}