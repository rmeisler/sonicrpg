local ItemType = require "util/ItemType"
local EventType = require "util/EventType"

return {
	name = "Blaster Armor",
	desc = "Press z to absorb 50% of incoming damage",
	type = ItemType.Armor,
	color = {0,0,0,255},
	usableBy = {"sonic", "sally", "antoine", "bunnie", "rotor", "logan"},
	stats = {
		defense = 2
	},
	event = {
		type = EventType.Z,
		action = require "data/battle/actions/Absorb"
	}
}
