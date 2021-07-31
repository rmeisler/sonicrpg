local ItemType = require "util/ItemType"

return {
	name = "Leather Sash",
	desc = "It's like a shoulder-belt...",
	type = ItemType.Accessory,
	color = {50,50,50,255},
	usableBy = {"rotor", "sally", "bunny", "sonic"},
	stats = {
		defense = 2,
		speed = -1
	}
}
