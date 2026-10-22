local ItemType = require "util/ItemType"

return {
	name = "Regen Suit",
	desc = "Regenerates 100 hp per turn.",
	type = ItemType.Armor,
	color = {0,0,0,255},
	usableBy = {"tails", "b", "sonic", "sally", "logan", "rotor", "antoine", "bunnie"},
	regen = {stat = "hp", per_turn = 100},
	stats = {
		defense = 1,
		speed = -1
	}
}
