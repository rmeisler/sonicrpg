local ItemType = require "util/ItemType"

return {
	name = "Yeti Armor",
	desc = "Protects against ice.",
	type = ItemType.Armor,
	color = {0,0,0,255},
	usableBy = {"sonic", "sally", "antoine", "bunnie", "rotor", "logan"},
	stats = {
		defense = 6
	}
}
