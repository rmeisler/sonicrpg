local TargetType = require "util/TargetType"

return {
	name = "Power Drain",
	target = TargetType.AllParty,
	cost = 3,
	desc = "Drains +1 sp from enemy each turn",
	action = require "data/battle/skills/actions/PowerDrain"
}