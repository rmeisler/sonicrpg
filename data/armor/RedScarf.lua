local ItemType = require "util/ItemType"

return {
	name = "Red Scarf",
	desc = "50% reduced damage from fire attacks",
	type = ItemType.Armor,
	color = {0,0,0,255},
	usableBy = {"sonic", "sally", "antoine", "bunnie", "rotor", "logan"},
	stats = {
		defense = 2
	}
}
