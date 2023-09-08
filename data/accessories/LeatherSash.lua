local ItemType = require "util/ItemType"

return {
	name = "Bandolier",
	desc = "Tough looking and stylish!",
	type = ItemType.Accessory,
	color = {50,50,50,255},
	usableBy = {"rotor", "sally", "bunny", "sonic", "logan"},
	stats = {
		defense = 2,
		speed = -1
	}
}
